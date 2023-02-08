use framework "AppKit"
use framework "Foundation"
use scripting additions

set actionDelay to 0.15

set screenDelay to 0.07

global stepDistance
global stepDistanceScreen
global stepsCount
global w

set stepDistance to 155
set stepDistanceScreen to stepDistance * 2
set stepsCount to 4
set {x, y} to {502, 168} -- screencapture x and y coordinates
set {w, h} to {74, stepDistance * (stepsCount - 1) + 1} -- screencapture width and height

activate application "Telegram"
delay 1


--tell application "System Events" to key code 124
--delay actionDelay
--tell application "System Events" to key code 124
--delay screenDelay

on getColors(pixel)
	set red to (pixel's redComponent()) * 255
	set green to (pixel's greenComponent()) * 255
	set blue to (pixel's blueComponent()) * 255
	
	return {red, green, blue}
end getColors

on isLeftShadow(red, green, blue)
	return red < 70
end isLeftShadow

on isRightShadow(red, green, blue)
	return red < 70
end isRightShadow

on getLeftShadowCoordinates(index)
	set y to getShadowY(index)
	set x to 2
	
	return {x, y}
end getLeftShadowCoordinates

on getRightShadowCoordinates(index)
	set y to getShadowY(index)
	set x to w * 2 - 2
	
	return {x, y}
end getRightShadowCoordinates

on getShadowY(index)
	return (index - 1) * stepDistanceScreen
end getShadowY

on isDead(red, green, blue)
	return red = 255
end isDead

on hit(side)
	set keyCode to 123
	
	if side = "right" then
		set keyCode to 124
	end if
	
	tell application "System Events" to key code keyCode
end hit

set counter to 0
set scrn to 0
set lastHit to "right"

repeat 35 times
	set scrn to scrn + 1
	set imageRep to null
	
	set screenTry to 0
	set isAnimated to false
	set hits to {}
	
	--log scrn
	
	repeat with index from 1 to stepsCount
		
		set counter to counter + 1
		
		repeat while index = 1 and isAnimated is not true
			--log "init screen..."
			set screenTry to screenTry + 1
			
			if screenTry = 3 then
				log "LAST HIT CHEAT"
				
				hit(lastHit)
				delay actionDelay
			else if screenTry = 5 then
				return "Потрачено"
			else
				set tempFile to POSIX path of ((path to desktop as text) & "screen" & scrn & ".bmp")
				do shell script "screencapture -R " & x & "," & y & "," & w & "," & h & " -t bmp -x " & quoted form of tempFile
				set imageRep to (current application's NSBitmapImageRep's imageRepWithContentsOfFile:tempFile)
				
				set {leftShadowX, leftShadowY} to getLeftShadowCoordinates(index)
				set leftPixel to (imageRep's colorAtX:leftShadowX y:leftShadowY)
				set {leftRed, leftGreen, leftBlue} to getColors(leftPixel)
				
				set isShadowOnLeft to isLeftShadow(leftRed, leftGreen, leftBlue)
				
				if isShadowOnLeft then
					set isAnimated to true
					set end of hits to "right"
					log "shadow LEFT"
				else
					set {rightShadowX, rightShadowY} to getRightShadowCoordinates(index)
					set rightPixel to (imageRep's colorAtX:rightShadowX y:rightShadowY)
					set {rightRed, rightGreen, rightBlue} to getColors(rightPixel)
					
					set isShadowOnRight to isRightShadow(rightRed, rightGreen, rightBlue)
					
					if isShadowOnRight then
						set isAnimated to true
						set end of hits to "left"
						log "shadow RIGHT"
					else
						delay screenDelay
					end if
					
				end if
			end if
		end repeat
		
		set {leftShadowX, leftShadowY} to getLeftShadowCoordinates(index)
		set leftPixel to (imageRep's colorAtX:leftShadowX y:leftShadowY)
		set {leftRed, leftGreen, leftBlue} to getColors(leftPixel)
		
		set isShadowOnLeft to isLeftShadow(leftRed, leftGreen, leftBlue)
		
		if index = 1 then
			--skip
		else if index = 4 and isDead(leftRed, leftGreen, leftBlue) then
			return "Потрачено"
		else
			if isShadowOnLeft then
				set end of hits to "right"
				log "shadow LEFT"
			else if index is not 4 or lastHit = "left" then
				set end of hits to "left"
				log "shadow RIGHT"
			else
				set {rightShadowX, rightShadowY} to getRightShadowCoordinates(index)
				set rightPixel to (imageRep's colorAtX:rightShadowX y:rightShadowY)
				set {rightRed, rightGreen, rightBlue} to getColors(rightPixel)
				
				set isShadowOnRight to isRightShadow(rightRed, rightGreen, rightBlue)
				
				if isShadowOnRight then
					log "shadow RIGHT"
					set end of hits to "left"
				else
					log "shadow LEFT, because right is not shadow" & counter
					set end of hits to "right"
				end if
			end if
		end if
	end repeat
	
	set hits to reverse of hits
	
	log hits
	
	repeat with hitIndex from 1 to stepsCount
		set hitSide to item hitIndex of hits
		
		hit(hitSide)
		
		delay actionDelay
		
		hit(hitSide)
		
		if hitIndex < stepsCount then
			delay actionDelay
		else if hitIndex = 3 then
			delay actionDelay + 0.1
		else
			set lastHit to hitSide
		end if
	end repeat
	
	
	
	delay screenDelay
	
end repeat
