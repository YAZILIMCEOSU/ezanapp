package com.yazilimceosu.ezanai

import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.hardware.GeomagneticField
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.media.RingtoneManager
import android.net.Uri
import android.net.wifi.WifiManager
import android.os.Build
import android.os.Debug
import android.os.PowerManager
import android.provider.Settings
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
    private var geomagneticRotationSensor: Sensor? = null
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
    private var lastMagAzimuth: Double? = null
    private var lastRotVecAzimuth: Double? = null
    private var gyroYawOffset: Double = 0.0
    private var hasGyroYawOffset: Boolean = false
    private var smoothedSin: Double = 0.0
    private var smoothedCos: Double = 1.0
    private var hasSmoothedHeading: Boolean = false
    private var lastEmittedHeading: Double = 0.0
    private var activeSensorSource: String = "initializing"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as? SensorManager
        rotationSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
        geomagneticRotationSensor =
            sensorManager?.getDefaultSensor(Sensor.TYPE_GEOMAGNETIC_ROTATION_VECTOR)
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
                    "hasCompass" -> result.success(
                        magnetometer != null || geomagneticRotationSensor != null || rotationSensor != null,
                    )
                    "hasAccelerometer" -> result.success(accelerometer != null)
                    "resetCompass" -> {
                        hasGravity = false
                        hasGeomagnetic = false
                        lastMagAzimuth = null
                        lastRotVecAzimuth = null
                        hasGyroYawOffset = false
                        hasSmoothedHeading = false
                        if (eventSink != null) {
                            startListening()
                        }
                        result.success(true)
                    }
                    "playSystemNotificationSound" -> {
                        val played = playSystemDefaultNotificationRingtone()
                        result.success(played)
                    }
                    "getSensorDiagnostics" -> {
                        result.success(
                            mapOf(
                                "hasMagnetometer" to (magnetometer != null),
                                "hasAccelerometer" to (accelerometer != null),
                                "hasRotationVector" to (rotationSensor != null),
                                "hasGeomagneticVector" to (geomagneticRotationSensor != null),
                                "lastMagAzimuth" to lastMagAzimuth,
                                "lastFusedHeading" to lastEmittedHeading,
                                "fieldStrengthMicroTesla" to lastFieldStrengthMicroTesla,
                                "magAccuracy" to lastMagAccuracy,
                                "sensorSource" to activeSensorSource,
                            ),
                        )
                    }
                    "getIntegrityInfo" -> result.success(buildIntegrityInfo())
                    "isIgnoringBatteryOptimizations" -> {
                        result.success(checkIgnoringBatteryOptimizations())
                    }
                    "requestIgnoreBatteryOptimizations" -> {
                        result.success(launchBatteryOptimizationExemption())
                    }
                    "getGeomagneticDeclination" -> {
                        val lat = (call.argument<Number>("lat")?.toFloat()) ?: 41.0082f
                        val lon = (call.argument<Number>("lon")?.toFloat()) ?: 28.9784f
                        val field = GeomagneticField(lat, lon, 0f, System.currentTimeMillis())
                        result.success(field.declination.toDouble())
                    }
                    "setSecureScreen" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        setSecureScreenFlag(enabled)
                        result.success(true)
                    }
                    "setAudioWakeLock" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        updateAudioWakeLock(enabled)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun checkIgnoringBatteryOptimizations(): Boolean {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val pm = applicationContext.getSystemService(Context.POWER_SERVICE) as? PowerManager
                pm?.isIgnoringBatteryOptimizations(applicationContext.packageName) ?: true
            } else {
                true
            }
        } catch (_: Throwable) {
            true
        }
    }

    @Suppress("BatteryLife")
    private fun launchBatteryOptimizationExemption(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
        val pkg = applicationContext.packageName
        try {
            val directIntent = Intent(
                Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                Uri.parse("package:$pkg"),
            )
            startActivity(directIntent)
            return true
        } catch (_: Throwable) {}
        return try {
            val listIntent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
            startActivity(listIntent)
            true
        } catch (_: Throwable) {
            false
        }
    }

    private fun setSecureScreenFlag(enabled: Boolean) {
        runOnUiThread {
            try {
                if (enabled) {
                    window?.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                } else {
                    window?.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                }
            } catch (_: Throwable) {}
        }
    }

    private fun playSystemDefaultNotificationRingtone(): Boolean {
        return try {
            val uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            if (uri != null) {
                val ringtone = RingtoneManager.getRingtone(applicationContext, uri)
                ringtone?.play()
                true
            } else {
                false
            }
        } catch (_: Throwable) {
            false
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
        val filesPath = try {
            applicationContext.filesDir.absolutePath.lowercase()
        } catch (_: Throwable) {
            ""
        }
        val cloneTokens = listOf("999", "parallel", "virtual", "dual", "multiapp", "shelter", "island")
        val isCloned = cloneTokens.any { token -> filesPath.contains(token) }

        val suspiciousPackages = listOf(
            "com.chelpus.lackypatch",
            "com.dimonvideo.luckypatcher",
            "com.forpda.lp",
            "com.android.vending.billing.InAppBillingService.COIN",
            "com.android.vending.billing.InAppBillingService.LUCK",
            "com.android.vending.billing.InAppBillingService.CRAC",
            "com.gmail.heagoo.apkeditor",
            "com.gmail.heagoo.apkeditor.pro",
            "de.robv.android.xposed.installer",
            "org.meowcat.edxposed.manager",
        )
        val hasPatcherApp = suspiciousPackages.any { target ->
            try {
                packageManager.getPackageInfo(target, 0)
                true
            } catch (_: Throwable) {
                false
            }
        }
        val hasXposedHook = try {
            Class.forName("de.robv.android.xposed.XposedBridge")
            true
        } catch (_: Throwable) {
            false
        }
        val isDebugBuild = (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
        val isDebuggerAttached = Debug.isDebuggerConnected() || Debug.waitingForDebugger()
        val hasTamper = hasPatcherApp || hasXposedHook || (!isDebugBuild && isDebuggerAttached)
        val isPlayInstall = installer == "com.android.vending" || installer == "com.google.android.feedback"

        return mapOf(
            "packageName" to pkg,
            "isOfficialPackage" to (isOfficial && !isCloned && !hasTamper),
            "installerPackage" to installer,
            "signingSha256" to sha256,
            "isClonedEnvironment" to isCloned,
            "hasTamperTools" to hasTamper,
            "isDebuggerAttached" to isDebuggerAttached,
            "isPlayStoreInstall" to isPlayInstall,
        )
    }

    private fun startListening() {
        stopListening()
        hasSmoothedHeading = false
        hasGyroYawOffset = false
        // Gerçek Manyetik Kuzey referansı için ACCELEROMETER + MAGNETIC_FIELD her zaman dinlenir
        // (bina içinde TYPE_ROTATION_VECTOR manyetometreyi reddettiğinde veya jiroskopsuz cihazlarda
        // pusulanın yanlış yöne kilitlenmesini %100 önler). Jiroskop/Rotasyon vektörü varsa
        // yalnızca sarsıntısız açısal hız yumuşatması için manyetik kuzeye kilitli olarak kullanılır.
        accelerometer?.let {
            sensorManager?.registerListener(this, it, SensorManager.SENSOR_DELAY_GAME)
        }
        magnetometer?.let {
            sensorManager?.registerListener(this, it, SensorManager.SENSOR_DELAY_GAME)
        }
        geomagneticRotationSensor?.let {
            sensorManager?.registerListener(this, it, SensorManager.SENSOR_DELAY_GAME)
        }
        rotationSensor?.let {
            sensorManager?.registerListener(this, it, SensorManager.SENSOR_DELAY_GAME)
        }
    }

    private fun stopListening() {
        sensorManager?.unregisterListener(this)
    }

    private var lastRotationVectorTimeMs = 0L

    private fun normalizeDegrees(deg: Double): Double = ((deg % 360.0) + 360.0) % 360.0

    private fun normalizeSigned(deg: Double): Double = ((deg + 540.0) % 360.0) - 180.0

    private fun extractAnglesFromMatrix(rotationMatrix: FloatArray): Triple<Double, Double, Double>? {
        val displayAdjusted = FloatArray(9)
        val (axisX, axisY) = when (currentSurfaceRotation()) {
            Surface.ROTATION_90 -> Pair(SensorManager.AXIS_Y, SensorManager.AXIS_MINUS_X)
            Surface.ROTATION_180 -> Pair(SensorManager.AXIS_MINUS_X, SensorManager.AXIS_MINUS_Y)
            Surface.ROTATION_270 -> Pair(SensorManager.AXIS_MINUS_Y, SensorManager.AXIS_X)
            else -> Pair(SensorManager.AXIS_X, SensorManager.AXIS_Y)
        }
        SensorManager.remapCoordinateSystem(rotationMatrix, axisX, axisY, displayAdjusted)

        val hx = displayAdjusted[0].toDouble()
        val hy = displayAdjusted[1].toDouble()
        val hz = displayAdjusted[2].toDouble()
        val mx = displayAdjusted[3].toDouble()
        val my = displayAdjusted[4].toDouble()
        val mz = displayAdjusted[5].toDouble()
        val ax = displayAdjusted[6].toDouble()
        val ay = displayAdjusted[7].toDouble()
        val az = displayAdjusted[8].toDouble()

        val yHorizMag = kotlin.math.hypot(hy, my)
        val uprightWeight = ((0.14 - yHorizMag) / 0.10).coerceIn(0.0, 1.0)
        val camSign = if (ay >= 0.0) -1.0 else 1.0
        val eastLvl = hy * (1.0 - uprightWeight) + (camSign * hz) * uprightWeight
        val northLvl = my * (1.0 - uprightWeight) + (camSign * mz) * uprightWeight

        val rawAzimuth = normalizeDegrees(Math.toDegrees(kotlin.math.atan2(eastLvl, northLvl)))
        val rawTiltDeg = Math.toDegrees(kotlin.math.asin((-ay).coerceIn(-1.0, 1.0)))
        val tiltDeg = if (az >= 0.0) rawTiltDeg * 0.62 else 60.0
        val rollDeg = Math.toDegrees(kotlin.math.asin(ax.coerceIn(-1.0, 1.0))) * 0.75
        if (!rawAzimuth.isFinite() || !tiltDeg.isFinite() || !rollDeg.isFinite()) return null
        return Triple(rawAzimuth, tiltDeg, rollDeg)
    }

    override fun onSensorChanged(event: SensorEvent) {
        when (event.sensor.type) {
            Sensor.TYPE_ACCELEROMETER -> {
                val alpha = 0.22f
                if (!hasGravity) {
                    System.arraycopy(event.values, 0, gravity, 0, 3)
                    hasGravity = true
                } else {
                    gravity[0] += alpha * (event.values[0] - gravity[0])
                    gravity[1] += alpha * (event.values[1] - gravity[1])
                    gravity[2] += alpha * (event.values[2] - gravity[2])
                }
                updateTrueMagneticReference()
            }
            Sensor.TYPE_MAGNETIC_FIELD -> {
                if (event.accuracy > 0) {
                    lastMagAccuracy = event.accuracy
                }
                val bx = event.values[0].toDouble()
                val by = event.values[1].toDouble()
                val bz = event.values[2].toDouble()
                val magnitude = kotlin.math.sqrt(bx * bx + by * by + bz * bz)
                if (magnitude.isFinite()) {
                    lastFieldStrengthMicroTesla = magnitude
                }
                val alpha = 0.22f
                if (!hasGeomagnetic) {
                    System.arraycopy(event.values, 0, geomagnetic, 0, 3)
                    hasGeomagnetic = true
                } else {
                    geomagnetic[0] += alpha * (event.values[0] - geomagnetic[0])
                    geomagnetic[1] += alpha * (event.values[1] - geomagnetic[1])
                    geomagnetic[2] += alpha * (event.values[2] - geomagnetic[2])
                }
                updateTrueMagneticReference()
            }
            Sensor.TYPE_GEOMAGNETIC_ROTATION_VECTOR -> {
                val rotationMatrix = FloatArray(9)
                val vec = if (event.values.size > 4) event.values.copyOfRange(0, 4) else event.values
                SensorManager.getRotationMatrixFromVector(rotationMatrix, vec)
                val angles = extractAnglesFromMatrix(rotationMatrix) ?: return
                lastMagAzimuth = angles.first
                val now = System.currentTimeMillis()
                if (now - lastRotationVectorTimeMs > 60) {
                    activeSensorSource = "geomagnetic_vector"
                    emitAngles(angles.first, angles.second, angles.third, lastMagAccuracy)
                }
            }
            Sensor.TYPE_ROTATION_VECTOR -> {
                val rotationMatrix = FloatArray(9)
                val vec = if (event.values.size > 4) event.values.copyOfRange(0, 4) else event.values
                SensorManager.getRotationMatrixFromVector(rotationMatrix, vec)
                val angles = extractAnglesFromMatrix(rotationMatrix) ?: return
                val rotAz = angles.first
                lastRotVecAzimuth = rotAz
                lastRotationVectorTimeMs = System.currentTimeMillis()

                // TYPE_ROTATION_VECTOR donanım sensör hub'ında kalibre edilmiş manyetometre + jiroskop kullanır.
                // Yalnızca TYPE_ROTATION_VECTOR gerçek manyetik kuzeyden >25° koptuysa (bina içi filtre kopması)
                // yumuşak düzeltme uygula; normal çalışmada (<25°) ham ivmeölçer titreşimini karıştırma.
                val magAz = lastMagAzimuth
                val anchoredAzimuth = if (magAz != null) {
                    val targetOffset = normalizeSigned(magAz - rotAz)
                    if (kotlin.math.abs(targetOffset) <= 25.0) {
                        gyroYawOffset = 0.0
                        hasGyroYawOffset = true
                        activeSensorSource = "fusion_mag_anchored"
                        rotAz
                    } else {
                        if (!hasGyroYawOffset) {
                            gyroYawOffset = targetOffset
                            hasGyroYawOffset = true
                        } else {
                            val offsetErr = normalizeSigned(targetOffset - gyroYawOffset)
                            gyroYawOffset = normalizeSigned(gyroYawOffset + 0.18 * offsetErr)
                        }
                        activeSensorSource = "fusion_mag_anchored"
                        normalizeDegrees(rotAz + gyroYawOffset)
                    }
                } else {
                    activeSensorSource = "rotation_vector"
                    rotAz
                }
                val effectiveAcc = if (event.accuracy > 0) event.accuracy else lastMagAccuracy
                emitAngles(anchoredAzimuth, angles.second, angles.third, effectiveAcc)
            }
        }
    }

    private var lastEmit = 0L

    private fun updateTrueMagneticReference() {
        if (!hasGravity || !hasGeomagnetic) return
        val rotationMatrix = FloatArray(9)
        if (!SensorManager.getRotationMatrix(rotationMatrix, null, gravity, geomagnetic)) return
        val angles = extractAnglesFromMatrix(rotationMatrix) ?: return
        lastMagAzimuth = angles.first
        val now = System.currentTimeMillis()
        // Eğer TYPE_ROTATION_VECTOR son 60 ms içinde tetiklenmediyse doğrudan gerçek manyetik matrisi yayınla
        if (now - lastRotationVectorTimeMs > 60) {
            activeSensorSource = "geomagnetic_matrix"
            emitAngles(angles.first, angles.second, angles.third, lastMagAccuracy)
        }
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

    private fun emitAngles(rawAzimuth: Double, tiltDeg: Double, rollDeg: Double, accuracy: Int) {
        val now = System.currentTimeMillis()
        if (now - lastEmit < 16) return // ~60 Hz anlık hassas pusula
        lastEmit = now

        // Adaptif dairesel filtre: telefonu çevirirken anında (0.68), sabit tutarken sarsıntısız (0.24)
        val rad = Math.toRadians(rawAzimuth)
        val s = kotlin.math.sin(rad)
        val c = kotlin.math.cos(rad)
        if (!hasSmoothedHeading) {
            smoothedSin = s
            smoothedCos = c
            hasSmoothedHeading = true
        } else {
            val prevDeg = normalizeDegrees(Math.toDegrees(kotlin.math.atan2(smoothedSin, smoothedCos)))
            val delta = kotlin.math.abs(normalizeSigned(rawAzimuth - prevDeg))
            val smoothFactor = if (delta > 3.5) 0.68 else 0.24
            smoothedSin += smoothFactor * (s - smoothedSin)
            smoothedCos += smoothFactor * (c - smoothedCos)
        }
        val smoothedDeg = Math.toDegrees(kotlin.math.atan2(smoothedSin, smoothedCos))
        val azimuthDegrees = normalizeDegrees(smoothedDeg).toFloat()
        lastEmittedHeading = azimuthDegrees.toDouble()

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
            "sensorSource" to activeSensorSource,
        )
        lastMagAzimuth?.let { payload["rawMagHeading"] = it }
        lastFieldStrengthMicroTesla?.let { payload["fieldStrength"] = it }
        eventSink?.success(payload)
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        if (sensor?.type == Sensor.TYPE_MAGNETIC_FIELD && accuracy > 0) {
            lastMagAccuracy = accuracy
        }
    }

    override fun onResume() {
        super.onResume()
        if (eventSink != null) {
            startListening()
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
