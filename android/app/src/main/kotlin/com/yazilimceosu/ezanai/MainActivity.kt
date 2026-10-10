package com.yazilimceosu.ezanai

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * Ezan ana aktivitesi.
 *
 * - Pusula (manyetometre + ivmeölçer) verisini platform kanalı üzerinden
 *   Flutter'a aktarır: kalibrasyon ve kıble hassasiyeti için gereklidir.
 */
class MainActivity : FlutterActivity(), SensorEventListener {
    private val channelName = "ezanai/sensors"
    private var eventSink: EventChannel.EventSink? = null
    private var sensorManager: SensorManager? = null
    private var rotationSensor: Sensor? = null
    private var accelerometer: Sensor? = null
    private var magnetometer: Sensor? = null

    private val gravity = FloatArray(3)
    private val geomagnetic = FloatArray(3)
    private var hasGravity = false
    private var hasGeomagnetic = false
    private var lastFieldStrengthMicroTesla: Double? = null

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
                    else -> result.notImplemented()
                }
            }
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
                SensorManager.getRotationMatrixFromVector(rotationMatrix, event.values)
                emitOrientation(rotationMatrix, event.accuracy)
            }
            Sensor.TYPE_ACCELEROMETER -> {
                System.arraycopy(event.values, 0, gravity, 0, 3)
                hasGravity = true
                emitFromGravityMagnetic()
            }
            Sensor.TYPE_MAGNETIC_FIELD -> {
                System.arraycopy(event.values, 0, geomagnetic, 0, 3)
                hasGeomagnetic = true
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
        emitOrientation(rotationMatrix, 3)
    }

    private fun emitOrientation(rotationMatrix: FloatArray, accuracy: Int) {
        val now = System.currentTimeMillis()
        if (now - lastEmit < 40) return // ~25 Hz yeterli
        lastEmit = now
        val orientation = FloatArray(3)
        SensorManager.getOrientation(rotationMatrix, orientation)
        val rawAzimuth = Math.toDegrees(orientation[0].toDouble())
        val tiltDeg = Math.toDegrees(orientation[1].toDouble())
        val rollDeg = Math.toDegrees(orientation[2].toDouble())
        if (!rawAzimuth.isFinite() || !tiltDeg.isFinite() || !rollDeg.isFinite()) return

        val azimuthDegrees = ((rawAzimuth + 360.0) % 360.0).toFloat()
        val accuracyDegrees = when (accuracy) {
            SensorManager.SENSOR_STATUS_ACCURACY_HIGH -> 3.0
            SensorManager.SENSOR_STATUS_ACCURACY_MEDIUM -> 8.0
            SensorManager.SENSOR_STATUS_ACCURACY_LOW -> 15.0
            else -> 25.0
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

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) = Unit

    override fun onPause() {
        super.onPause()
        if (eventSink == null) stopListening()
    }
}
