STAGE.
SET speed TO  0.
LOCK THROTTLE TO speed.
LOCK DIRECTION TO UP.
LOCK T to TIME:SECONDS.
WAIT 5.
SET target_height TO 10.
SET p TO 0.1.
SET d TO 0.05.
SET error TO ERR.
SET d_error TO 0.
LOCK ERR TO target_height - ALT:RADAR.
LOCK speed TO MAX(d*d_error + p*ERR, 0).
SET t0 TO T.
LOCK DT TO T - t0.
UNTIL FALSE {
	SET delta_time TO DT.
	IF delta_time > 0 {
		PRINT diff.
		SET d_error TO (ERR-error) / delta_time.
		SET error TO ERR.
		//SET err TO err+error. //THIS IS THE I TERM
		SET t0 TO T.
	}
	WAIT 0.001.
}
