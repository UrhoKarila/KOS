//Vars
SET display_refresh_rate TO .5.
SET height_mode to "RDR".
SET height_setpoint TO 15.

//Variables for vKp, vKi, and vKd
//can fold with ctrl+shft+[
//Recalculating these values, in case the SET was not evaluating the expression correctly
//SET Ku TO 0.12.
//SET Tu TO 3.0.
//SET vKp TO 0.6 * Ku.
//SET vKp TO .072.
//SET vKi TO 2 * vKp / Tu.
//SET vKi TO .048.
//SET vKd TO vKp * Tu / 8.0.
//SET vKd TO .027.

//Modified values -- pulled from anus
SET vKp TO .12.
SET vKi TO .02.
SET vKd TO .075.

SET lKp to .1.
SET lKi to .02.
SET Lkd to .1.

//Modified values -- aggressive throttle use?
//SET vKp TO .15.
//SET vKi TO .02.
//SET vKd TO .1.

//Original values -- work well
//SET vKp TO 0.1.
//SET vKi TO 0.01.
//SET vKd TO 0.05.

//Initial setup of craft: spools engines and ensures a clean takeoff
LOCK STEERING TO UP.
SET THROTTLE TO .05.
SAS ON.
RCS ON.
STAGE.
WAIT 2.

LOCK height TO ALT:RADAR.
LOCK forward_velocity to VXCL(SHIP:FACING:STARVECTOR, VXCL(SHIP:UP:VECTOR, SHIP:VELOCITY:SURFACE)):MAG.
LOCK lateral_velocity to VXCL(SHIP:FACING:UP, VXCL(SHIP:UP:VECTOR, SHIP:VELOCITY:SURFACE)):MAG.

LOCK vP TO height_setpoint - height.
SET vI TO 0.
SET vD TO 0.
SET vP0 TO vP.

LOCK thrott TO vKp * vP + vKi * vI + vKd * vD.
LOCK THROTTLE to thrott.


//Get to height after takeoff before handing off controls to pilot
//WAIT 4.
UNLOCK STEERING.
CLEARSCREEN.

SET t0 TO TIME:SECONDS.
SET display_timer to TIME:SECONDS.
UNTIL FALSE {
	SET dt TO TIME:SECONDS - t0.

	//THROTTLE
	IF dt > 0 {
		//PRINT height.
		SET vI TO vI + vP * dt.
		SET vD TO (vP - vP0) / dt.
		SET vP0 TO vP.
		SET t0 TO TIME:SECONDS.
	}

	//DISPLAY
	IF TIME:SECONDS - display_timer > display_refresh_rate{
		SET display_timer TO TIME:SECONDS.
		PRINT "height_setpoint is: " + ROUND(height_setpoint, 1) AT(1,1).
		PRINT "Curent height is:   " + ROUND(ALT:RADAR) AT(1,2).
		PRINT "Cumulative vI is: " + ROUND(vI, 2) AT(1,4).
		PRINT "Current Mode is: " + height_mode AT(terminal:width/2 - 10, 6).
		PRINT "Current forward_velocity is : " + ROUND(forward_velocity,3) AT (2, 8).
		PRINT "Current lateral_velocity is :" + ROUND(lateral_velocity,3) AT (2,9).
	}


	//Adding some altitude controls
	//Increase height
	ON AG1{
		CLEARSCREEN.
		SET height_setpoint TO height_setpoint + 1.
		PRINT "Increased height to " + height_setpoint.
	}
	//decrease height
	ON AG2{
		CLEARSCREEN.
		SET height_setpoint TO height_setpoint - 1.
		PRINT "Decreased height to " + height_setpoint.
	}
	//Toggle between flying based on Radar altutude or Altitude ASL
	ON AG3{
		if(height_mode = "RDR"){
			SET height_mode TO "ASL".
			LOCK height TO SHIP:ALTITUDE.
			SET height_setpoint TO SHIP:ALTITUDE.
		}
		else{
			SET height_mode TO "RDR".
			LOCK height TO ALT:RADAR.
			SET height_setpoint TO ALT:RADAR.
		}
	}

	WAIT 0.001.
}