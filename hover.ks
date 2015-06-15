//Initial setup of craft: spools engines and ensures a clean takeoff
LOCK STEERING TO UP.
SET THROTTLE TO .05.
STAGE.
WAIT 2.

LOCK height TO ALT:RADAR.
SET height_mode to "RDR".
SET height_setpoint TO 15.

LOCK P TO height_setpoint - height.
SET I TO 0.
SET D TO 0.
SET P0 TO P.

//Variables for Kp, Ki, and Kd
//can fold with ctrl+shft+[
//Recalculating these values, in case the SET was not evaluating the expression correctly
//SET Ku TO 0.12.
//SET Tu TO 3.0.
//SET Kp TO 0.6 * Ku.
SET Kp TO .072.
//SET Ki TO 2 * Kp / Tu.
SET Ki TO .048.
//SET Kd TO Kp * Tu / 8.0.
SET Kd TO .027.

//Modified values -- pulled from anus
//SET Kp TO .12.
//SET Ki TO .02.
//SET Kd TO .075.

//Modified values -- aggressive throttle use?
//SET Kp TO .15.
//SET Ki TO .02.
//SET Kd TO .1.

//Original values -- work well
//SET Kp TO 0.1.
//SET Ki TO 0.01.
//SET Kd TO 0.05.

LOCK thrott TO Kp * P + Ki * I + Kd * D.
LOCK THROTTLE to thrott.


//Get to height after takeoff before handing off controls to pilot
WAIT 4.
UNLOCK STEERING.

SET t0 TO TIME:SECONDS.
SET display_timer to TIME:SECONDS.
UNTIL FALSE {
	SET dt TO TIME:SECONDS - t0.
	//Controls
	IF dt > 0 {
		//PRINT height.
		SET I TO I + P * dt.
		SET D TO (P - P0) / dt.
		SET P0 TO P.
		SET t0 TO TIME:SECONDS.
	}
	//Informational Display
	IF TIME:SECONDS - display_timer > 1{
		SET display_timer TO TIME:SECONDS.
		CLEARSCREEN.
		PRINT "height_setpoint is: " + MATH:ROUND(height_setpoint, 1) AT(1,1).
		PRINT "Curent height is:   " + MATH:ROUND(SHIP:ALTITUDE) AT(2,1).
		PRINT "Cumulative I is: " + MATH:ROUND(I, 2) AT(4,1).
		PRINT "Current Mode is: " + height_mode AT(6,TERMINAL:WIDTH - 10).
	}
	WAIT 0.001.
}

//Adding some altitude controls
//Increase height
ON AG1{
	SET height_setpoint TO height_setpoint + 1.
	PRINT "Increased height to " + height_setpoint.
}

//decrease height
ON AG2{
	SET height_setpoint TO height_setpoint - 1.
	PRINT "Increased height to " + height_setpoint.
}

//Toggle between flying based on Radar altutude or Altitude ASL
ON AG3{
	if(height_mode = "RDR"){
		SET height_mode TO "ASL".
		LOCK height TO SHIP:ALTITUDE.
		LOCK height_setpoint TO SHIP:ALTITUDE.
	}
	else{
		SET height_mode TO "RDR".
		LOCK height TO ALT:RADAR.
		LOCK height_setpoint TO ALT:RADAR.
	}
}