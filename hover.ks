STAGE.

LOCK height TO ALT:RADAR.
SET height_setpoint TO 1.2.

LOCK P TO height_setpoint - height.
SET I TO 0.
SET D TO 0.
SET P0 TO P.

SET Kp TO 0.1.
SET Ki TO 0.006.
SET Kd TO 0.006.

LOCK thrott TO Kp * P + Ki * I + Kd * D.
LOCK THROTTLE to thrott.

SET t0 TO TIME:SECONDS.
UNTIL FALSE {
	SET dt TO TIME:SECONDS - t0.
	IF dt > 0 {
		PRINT height.
		SET I TO I + P * dt.
		SET D TO (P - P0) / dt.
		SET P0 TO P.
		SET t0 TO TIME:SECONDS.
	}
	WAIT 0.001.
}
