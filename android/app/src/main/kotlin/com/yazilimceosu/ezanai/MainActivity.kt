package com.yazilimceosu.ezanai

import android.content.Context
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.net.wifi.WifiManager
import android.os.Build
import android.os.PowerManager
import android.view.Surface
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest

/**
 * Ezan ana aktivitesi.
 *
 * - Pusula (manyetometre + ivmeölçer) verisini platform kanalı üzerinden
 *   Flutter'a aktarır: kalibrasyon ve kıble hassasiyeti için gereklidir.
 * - Ezan, Kur'an ve ilahi oynatılırken ekran kapansa bile sesin 30-40 sn
 *   sonra kesilmemesi için donanım WakeLock ve WifiLock kilidi yönetir.
 */
class MainActivity : FlutterActivity(), SensorEventListener {
    private val channelName = "ezanai/sensors"
    private var eventSink: EventChannel.EventSink? = null
    private var sensorManager: SensorManager? = null
    private var rotationSensor: Sensor? = null
    private var accelerometer: Sensor? = null
    private var magnetometer: Sensor? = null
    private var audioWakeLock: PowerManager.WakeLock? = null
    private var audioWifiLock: WifiManager.WifiLock? = null

    private val gravity = FloatArray(3)
    private val geomagnetic = FloatArray(3)
    private var hasGravity = false
    private var hasGeomagnetic = false
    private var lastFieldStrengthMicroTesla: Double? = null
    private var lastMagAccuracy: Int = SensorManager.SENSOR_STATUS_ACCURACY_HIGH
    private var smoothedSin: Double = 0.0
    private var smoothedCos: Double = 1.0
    private var hasSmoothedHeading: Boolean = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as? SensorManager
        rotationSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
        accelerometer = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        magnetometer = sensorManager?.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    startListening()
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                    stopListening()
                }
            })

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "$channelName/methods")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasCompass" -> result.success(rotationSensor != null || magnetometer != null)
                    "hasAccelerometer" -> result.success(accelerometer != null)
                    "getIntegrityInfo" -> result.success(buildIntegrityInfo())
                    "setAudioWakeLock" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        updateAudioWakeLock(enabled)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun updateAudioWakeLock(enabled: Boolean) {
        try {
            runOnUiThread {
                try {
                    if (enabled) {
                        window?.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    } else {
                        window?.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    }
                } catch (_: Throwable) {}
            }
            if (enabled) {
                if (audioWakeLock == null) {
                    val pm = applicationContext.getSystemService(Context.POWER_SERVICE) as? PowerManager
                    audioWakeLock = pm?.newWakeLock(
                        PowerManager.PARTIAL_WAKE_LOCK,
                        "ezanai:audio_playback",
                    )?.apply { setReferenceCounted(false) }
                }
                if (audioWakeLock?.isHeld == false) {
                    // En fazla 25 dakika (uzun sure / ezan tilaveti boyunca CPU uyanık kalır)
                    audioWakeLock?.acquire(25 * 60 * 1000L)
                }
                if (audioWifiLock == null) {
                    val wm = applicationContext.getSystemService(Context.WIFI_SERVICE) as? WifiManager
                    @Suppress("DEPRECATION")
                    val lockMode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        WifiManager.WIFI_MODE_FULL_LOW_LATENCY
                    } else {
                        WifiManager.WIFI_MODE_FULL_HIGH_PERF
                    }
                    audioWifiLock = wm?.createWifiLock(lockMode, "ezanai:audio_wifi")?.apply {
                        setReferenceCounted(false)
                    }
                }
                if (audioWifiLock?.isHeld == false) {
                    audioWifiLock?.acquire()
                }
            } else {
                if (audioWakeLock?.isHeld == true) {
                    audioWakeLock?.release()
                }
                if (audioWifiLock?.isHeld == true) {
                    audioWifiLock?.release()
                }
            }
        } catch (_: Throwable) {}
    }

    private fun buildIntegrityInfo(): Map<String, Any?> {
        val pkg = applicationContext.packageName
        val isOfficial = pkg == "com.yazilimceosu.ezanai" || pkg == "com.yazilimceosu.ezanai.debug"
        val installer = try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                packageManager.getInstallSourceInfo(pkg).installingPackageName
            } else {
                @Suppress("DEPRECATION")
                packageManager.getInstallerPackageName(pkg)
            }
        } catch (_: Throwable) {
            null
        }
        val sha256 = try {
            val bytes = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                val info = packageManager.getPackageInfo(
                    pkg,
                    PackageManager.GET_SIGNING_CERTIFICATES,
                )
                val signers = info.signingInfo?.apkContentsSigners
                if (signers != null && signers.isNotEmpty()) signers[0].toByteArray() else null
            } else {
                @Suppress("DEPRECATION")
                val info = packageManager.getPackageInfo(pkg, PackageManager.GET_SIGNATURES)
                @Suppress("DEPRECATION")
                val sigs = info.signatures
                if (sigs != null && sigs.isNotEmpty()) sigs[0].toByteArray() else null
            }
            if (bytes != null) {
                MessageDigest.getInstance("SHA-256")
                    .digest(bytes)
                    .joinToString("") { "%02x".format(it) }
            } else {
                null
            }
        } catch (_: Throwable) {
            null
        }
        return mapOf(
            "packageName" to pkg,
            "isOfficialPackage" to isOfficial,
            "installerPackage" to installer,
            "signingSha256" to sha256,
        )
    }

    private fun startListening() {
        rotationSensor?.let {
            sensorManager?.registerListener(this, it, SensorManager.SENSOR_DELAY_GAME)
            magnetometer?.let { mag ->
                sensorManager?.registerListener(this, mag, SensorManager.SENSOR_DELAY_UI)
            }
        } ?: run {
            accelerometer?.let { sensorManager?.registerListener(this, it, SensorManager.SENSOR_DELAY_GAME) }
            magnetometer?.let { sensorManager?.registerListener(this, it, SensorManager.SENSOR_DELAY_GAME) }
        }
    }

    private fun stopListening() {
        sensorManager?.unregisterListener(this)
    }

    override fun onSensorChanged(event: SensorEvent) {
        when (event.sensor.type) {
            Sensor.TYPE_ROTATION_VECTOR -> {
                val rotationMatrix = FloatArray(9)
                val vec = if (event.values.size > 4) event.values.copyOfRange(0, 4) else event.values
                SensorManager.getRotationMatrixFromVector(rotationMatrix, vec)
                val effectiveAcc = if (event.accuracy > 0) event.accuracy else lastMagAccuracy
                emitOrientation(rotationMatrix, effectiveAcc)
            }
            Sensor.TYPE_ACCELEROMETER -> {
                val alpha = 0.18f
                if (!hasGravity) {
                    System.arraycopy(event.values, 0, gravity, 0, 3)
                    hasGravity = true
                } else {
                    gravity[0] += alpha * (event.values[0] - gravity[0])
                    gravity[1] += alpha * (event.values[1] - gravity[1])
                    gravity[2] += alpha * (event.values[2] - gravity[2])
                }
                if (rotationSensor == null) {
                    emitFromGravityMagnetic()
                }
            }
            Sensor.TYPE_MAGNETIC_FIELD -> {
                if (event.accuracy > 0) {
                    lastMagAccuracy = event.accuracy
                }
                val alpha = 0.18f
                if (!hasGeomagnetic) {
                    System.arraycopy(event.values, 0, geomagnetic, 0, 3)
                    hasGeomagnetic = true
                } else {
                    geomagnetic[0] += alpha * (event.values[0] - geomagnetic[0])
                    geomagnetic[1] += alpha * (event.values[1] - geomagnetic[1])
                    geomagnetic[2] += alpha * (event.values[2] - geomagnetic[2])
                }
                val bx = event.values[0].toDouble()
                val by = event.values[1].toDouble()
                val bz = event.values[2].toDouble()
                val magnitude = kotlin.math.sqrt(bx * bx + by * by + bz * bz)
                if (magnitude.isFinite()) {
                    lastFieldStrengthMicroTesla = magnitude
                }
                if (rotationSensor == null) {
                    emitFromGravityMagnetic()
                }
            }
        }
    }

    private var lastEmit = 0L

    private fun emitFromGravityMagnetic() {
        if (!hasGravity || !hasGeomagnetic) return
        val rotationMatrix = FloatArray(9)
        if (!SensorManager.getRotationMatrix(rotationMatrix, null, gravity, geomagnetic)) return
        emitOrientation(rotationMatrix, lastMagAccuracy)
    }

    @Suppress("DEPRECATION")
    private fun currentSurfaceRotation(): Int {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                display?.rotation ?: Surface.ROTATION_0
            } else {
                windowManager?.defaultDisplay?.rotation ?: Surface.ROTATION_0
            }
        } catch (_: Throwable) {
            Surface.ROTATION_0
        }
    }

    private fun emitOrientation(rotationMatrix: FloatArray, accuracy: Int) {
        val now = System.currentTimeMillis()
        if (now - lastEmit < 35) return // ~28 Hz akıcı pusula
        lastEmit = now

        // Ekran yönüne (portre/yatay) göre koordinat sistemini eşle
        val displayAdjusted = FloatArray(9)
        val (axisX, axisY) = when (currentSurfaceRotation()) {
            Surface.ROTATION_90 -> Pair(SensorManager.AXIS_Y, SensorManager.AXIS_MINUS_X)
            Surface.ROTATION_180 -> Pair(SensorManager.AXIS_MINUS_X, SensorManager.AXIS_MINUS_Y)
            Surface.ROTATION_270 -> Pair(SensorManager.AXIS_MINUS_Y, SensorManager.AXIS_X)
            else -> Pair(SensorManager.AXIS_X, SensorManager.AXIS_Y)
        }
        SensorManager.remapCoordinateSystem(rotationMatrix, axisX, axisY, displayAdjusted)

        val orientation = FloatArray(3)
        SensorManager.getOrientation(displayAdjusted, orientation)
        val tiltDeg = Math.toDegrees(orientation[1].toDouble())
        val rollDeg = Math.toDegrees(orientation[2].toDouble())

        // Telefon dik/yarı dik tutuluyorsa (eğim > 55°) gimbal kilitlenmesini önlemek için Z eksenini kullan
        val rawAzimuth = if (kotlin.math.abs(tiltDeg) > 55.0) {
            val uprightMatrix = FloatArray(9)
            SensorManager.remapCoordinateSystem(
                displayAdjusted,
                SensorManager.AXIS_X,
                SensorManager.AXIS_Z,
                uprightMatrix,
            )
            val uprightOrientation = FloatArray(3)
            SensorManager.getOrientation(uprightMatrix, uprightOrientation)
            Math.toDegrees(uprightOrientation[0].toDouble())
        } else {
            Math.toDegrees(orientation[0].toDouble())
        }
        if (!rawAzimuth.isFinite() || !tiltDeg.isFinite() || !rollDeg.isFinite()) return

        // Dairesel üstel yumuşatma (titreşimsiz Diyanet pusulası kararlılığı)
        val rad = Math.toRadians(rawAzimuth)
        val s = kotlin.math.sin(rad)
        val c = kotlin.math.cos(rad)
        if (!hasSmoothedHeading) {
            smoothedSin = s
            smoothedCos = c
            hasSmoothedHeading = true
        } else {
            val smoothFactor = 0.25
            smoothedSin += smoothFactor * (s - smoothedSin)
            smoothedCos += smoothFactor * (c - smoothedCos)
        }
        val smoothedDeg = Math.toDegrees(kotlin.math.atan2(smoothedSin, smoothedCos))
        val azimuthDegrees = ((smoothedDeg + 360.0) % 360.0).toFloat()

        val accuracyDegrees = when (accuracy) {
            SensorManager.SENSOR_STATUS_ACCURACY_HIGH -> 3.0
            SensorManager.SENSOR_STATUS_ACCURACY_MEDIUM -> 8.0
            SensorManager.SENSOR_STATUS_ACCURACY_LOW -> 15.0
            else -> 12.0
        }
        val payload = mutableMapOf<String, Any>(
            "heading" to azimuthDegrees.toDouble(),
            "accuracy" to accuracyDegrees,
            "tilt" to tiltDeg,
            "roll" to rollDeg,
        )
        lastFieldStrengthMicroTesla?.let { payload["fieldStrength"] = it }
        eventSink?.success(payload)
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        if (sensor?.type == Sensor.TYPE_MAGNETIC_FIELD && accuracy > 0) {
            lastMagAccuracy = accuracy
        }
    }

    override fun onPause() {
        super.onPause()
        if (eventSink == null) stopListening()
    }

    override fun onDestroy() {
        updateAudioWakeLock(false)
        super.onDestroy()
    }
}
