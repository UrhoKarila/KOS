PRINT "Welcome to altitude hold v0".
SET alt_input to GetInt("Set target altitude (m): ").
SET climb_angle to GetInt( "Enter climb rate (degrees): ").

PRINT ALLWAYPOINTS().
SET waypoint_name to GetLine("SELECT A WAYPOINT").

LOCK waypoint_heading to WAYPOINT(waypoint_name):GEOPOSITION:HEADING.
LOCK waypoint_bearing to WAYPOINT(waypoint_name):GEOPOSITION:BEARING.

SET KpA TO .03.
SET KdA TO .02.
SET KiA to 0.0001.

SET PID_A TO PIDLOOP(KpA, KiA, KdA).

SET PID_A:MAXOUTPUT TO  climb_angle.
SET PID_A:MINOUTPUT TO -climb_angle.

//------------------------------------

SET MAX_PITCH_OUTPUT TO .15.

SET KpP TO .02.
SET KdP TO .00.
SET KiP TO .0.

SET PID_P TO PIDLOOP(KpP, KdP, KiP).

SET PID_P:MAXOUTPUT TO MAX_PITCH_OUTPUT.
SET PID_P:MINOUTPUT TO MAX_PITCH_OUTPUT * -1.


//------------------------------------

SET MAX_ROLL_ANGLE TO 45.

SET KpD TO .05.
SET KdD TO .0.
SET KiD TO 0.

SET PID_D TO PIDLOOP(KpD, KdD, KiD).

SET PID_D:MAXOUTPUT TO MAX_ROLL_ANGLE.
SET PID_D:MINOUTPUT TO MAX_ROLL_ANGLE * -1.

//-----------------------------------


SET MAX_ROLL_OUTPUT TO .05.

SET KpR TO .04.
SET KdR TO .06.
SET KiR TO 0.

SET PID_R TO PIDLOOP(KpR, KdR, KiR).

SET PID_R:MAXOUTPUT TO MAX_ROLL_OUTPUT.
SET PID_R:MINOUTPUT TO MAX_ROLL_OUTPUT * -1.

//------------------------------------



FUNCTION ConfigurePitch
{
	
}

function PlaneHeading{
	SET northPole TO latlng(90,0).
	RETURN MOD(-northPole:BEARING + 360, 360).
}

function GetLine{
	PARAMETER PROMPT.

	PRINT PROMPT.


	SET value to "".
	UNTIL FALSE{
		PRINT value AT (2,2).
		set ch TO terminal:input:GETCHAR().
		IF(ch = "."){
			BREAK.
		}
		ELSE IF ch = TERMINAL:INPUT:BACKSPACE{
		SET value TO "".
		}
		ELSE{
			set value to (value + ch).
		}
	}

	RETURN value.
}

function GetInt{
	PARAMETER PROMPT.
	RETURN GetLine(PROMPT):ToScalar().
}



PRINT "Climbing to "+alt_input+"m height at "+climb_angle+ " degrees.".

//UNTIL (CORE:VESSEL:ALTITUDE >= CORE:VESSEL:ALT){
//	LOCK STEERING TO R(climb_angle, PlaneHeading(), 0).
//}

UNTIL FALSE
{
	CLEARSCREEN.
	

	SET desiredPitch TO PID_A:UPDATE(TIME:SECONDS,  ( ALT:RADAR - alt_input)).
	//PRINT "ALTITUDE ERROR: " + (ALT:RADAR -alt_input ) at (2,2).
	//PRINT "DESIRED PITCH SET:   " + desiredPitch AT (2,3).

	//PRINT "I TERM: " + PID_A:ITERM.

	PRINT "CLIMB ANGLE SET TO: " + climb_angle AT (2, 5).
	SET actualClimbAngle TO ARCSIN(SHIP:VERTICALSPEED / SHIP:AIRSPEED).
	//PRINT "ASSUMED CLIMB ANGLE: " + actualClimbAngle AT (1, 6).

	SET pitchOut TO PID_P:UPDATE(TIME:SECONDS, actualClimbAngle - desiredPitch ).

	//PRINT "OUTPUT PITCH DESIRED: " + pitchOut.

	SET SHIP:CONTROL:PITCH TO pitchOut.



//-------------------------------

	PRINT "DISTANCE TO CURRENT WAYPOINT: " + WAYPOINT("KSC"):GEOPOSITION:DISTANCE.
	PRINT "BEARING TO CURRENT WAYPOINT: " + waypoint_bearing AT (2,6).
	SET bearVal TO PID_D:UPDATE(TIME:SECONDS, waypoint_bearing).

	SET actualRoll TO (90 - VECTORANGLE(UP:VECTOR, SHIP:FACING:STARVECTOR)).
	PRINT "ASSUMED ROLL ANGLE " + actualRoll.

	SET rollVal TO PID_R:UPDATE(TIME:SECONDS, bearVal - actualRoll).

	PRINT "DESIRED ROLL: " + bearVal.
	PRINT "EXPECTED ROLL OUTPUT disabled: " + rollval.

	//SET SHIP:CONTROL:ROLL TO rollval.
	SET SHIP:CONTROL:ROLL TO SHIP:CONTROL:PILOTROLL.

	WAIT .5.
}

//LOCK STEERING TO HEADING(PlaneHeading(), 0).