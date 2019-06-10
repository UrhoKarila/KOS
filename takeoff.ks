function GetLine{
	PARAMETER PROMPT.

	PRINT PROMPT.


	SET value to "".
	UNTIL FALSE{
		set ch TO terminal:input:GETCHAR().
		IF(ch = "."){
			BREAK.
		}
		ELSE{
			set value to (value + ch).
		}
	}

	RETURN value.
}

SET takeoffSpeed TO GetLine("ENTER TAKEOFF SPEED (m/s): "):TOSCALAR().

SET flareAngle TO GetLine( "ENTER TAKEOFF FLARE (degrees): "):TOSCALAR().

function PlaneHeading{
	SET northPole TO latlng(90,0).
	RETURN MOD(-northPole:BEARING + 360, 360).
}


STAGE.
LOCK THROTTLE TO 1.

WAIT 1.

SET CURRENTVALUE TO 0.

SET wKp to 0.01.
SET wKd to 0.01.
SET wKi to 0.001.
SET WheelsteerPID to PIDLOOP(wKp,wKi,wKd).

SET WheelsteerPID:MAXOUTPUT TO 0.5.
SET WheelsteerPID:MINOUTPUT TO -0.5.

LOCK STEERING TO HEADING(90, 1).

LOCK ERRIn TO (90 - PlaneHeading).

SET flared TO FALSE.

UNTIL SHIP:ALTITUDE > 100 {
	CLEARSCREEN.

	IF (ROUND(CORE:VESSEL:AIRSPEED , 0) > takeoffSpeed) AND (NOT flared)
	{
		SET flared TO TRUE.
		LOCK STEERING TO HEADING(90, flareAngle).
	}

	SET CURRENTVALUE to WheelsteerPID:UPDATE(TIME:SECONDS, ERRIn).

	PRINT "PID OUTPUT: " + CURRENTVALUE AT (2,2).
	PRINT "ERROR: " + ERRIn AT (3,3).
	PRINT "SETPOINT: " + WheelsteerPID:SETPOINT() AT (2,5).
	PRINT ROUND(CORE:VESSEL:AIRSPEED , 0) + ", target = " + takeoffSpeed AT(2, 7).
	PRINT "EXCEEDED FLARE SPEED? " + (ROUND(CORE:VESSEL:AIRSPEED , 0) > takeoffSpeed) AT (2, 8).
	PRINT "FLARED: "+ flared AT (2,9).

	SET SHIP:CONTROL:WHEELSTEER TO CURRENTVALUE.
	WAIT 0.1.
}


//WAIT UNTIL CORE:VESSEL:AIRSPEED > takeoffSpeed:TOSCALAR().
//PRINT CORE:VESSEL:AIRSPEED + ", target = " + takeoffSpeed.


UNTIL ALT:RADAR > 500{
	WAIT 1.

}


SET THROTTLE TO 1.
UNLOCK THROTTLE.
UNLOCK STEERING.