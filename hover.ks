STAGE.
WAIT 2.

LOCK height TO ALT:RADAR.
SET height_setpoint TO 15.

LOCK P TO height_setpoint - height.
SET I TO 0.
SET D TO 0.
SET P0 TO P.

//SET Ku TO 0.12.
//SET Tu TO 3.0.
//SET Kp TO 0.6 * Ku.
//SET Ki TO 2 * Kp / Tu.
//SET Kd TO Kp * Tu / 8.0.
SET Kp TO 0.1.
SET Ki TO 0.01.
SET Kd TO 0.05.

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
