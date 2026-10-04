package com.yazilimceosu.ezanai

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * EzanAI ana aktivitesi.
 *
 * - Arka planda ses oynatma için [AudioServiceActivity] tabanlıdır.
 * - Pusula (manyetometre + ivmeölçer) verisini platform kanalı üzerinden
 *   Flutter'a aktarır: kalibrasyon ve kıble hassasiyeti için gereklidir.
 */
class MainActivity : AudioServiceActivity(), SensorEventListener {
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
                emitFromGravityMagnetic()
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
        val azimuthDegrees = ((Math.toDegrees(orientation[0].toDouble()) + 360.0) % 360.0).toFloat()
        val accuracyDegrees = when (accuracy) {
            SensorManager.SENSOR_STATUS_ACCURACY_HIGH -> 3.0
            SensorManager.SENSOR_STATUS_ACCURACY_MEDIUM -> 8.0
            SensorManager.SENSOR_STATUS_ACCURACY_LOW -> 15.0
            else -> 25.0
        }
        eventSink?.success(
            mapOf(
                "heading" to azimuthDegrees.toDouble(),
                "accuracy" to accuracyDegrees,
                "tilt" to Math.toDegrees(orientation[1].toDouble()),
                "roll" to Math.toDegrees(orientation[2].toDouble()),
            ),
        )
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) = Unit

    override fun onPause() {
        super.onPause()
        if (eventSink == null) stopListening()
    }
}
