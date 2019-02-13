
// Project: Populous 
// Created: 2019-02-13

// show all errors
SetErrorMode(2)

#constant screenwidth=1024
#constant screenheight=768
#constant fullscreen=1
#constant screenrate=0

// set window properties
SetWindowTitle( "Populous" )
SetWindowSize( screenwidth, screenheight, fullscreen )
SetWindowAllowResize( 1 ) // allow the user to resize the window

// set display properties
SetVirtualResolution( screenwidth, screenheight ) // doesn't have to match the window
SetOrientationAllowed( 1, 1, 1, 1 ) // allow both portrait and landscape on mobile devices
SetSyncRate( screenrate, 0 ) // 30fps instead of 60 to save battery
SetScissor( 0,0,0,0 ) // use the maximum available screen space, no black borders
UseNewDefaultFonts( 1 ) // since version 2.0.22 we can use nicer default fonts

#constant mapsize=50
type _map
	x#
	z#
	id#
	height#
endtype
global map as _map[mapsize,mapsize]



land = CreateObjectBox(.1,.1,.1)
border1 = CreateObjectCylinder(9,.1,20)
SetObjectPosition(border1,-4.5,0,0)
SetObjectRotation(border1,90,0,0)
FixObjectToObject(border1,land)

border2 = CreateObjectCylinder(9,.1,20)
SetObjectPosition(border2,4.5,0,0)
SetObjectRotation(border2,90,0,0)
FixObjectToObject(border2,land)

border3 = CreateObjectCylinder(9,.1,20)
SetObjectPosition(border3,0,0,-4.5)
SetObjectRotation(border3,0,0,90)
FixObjectToObject(border3,land)

border4 = CreateObjectCylinder(9,.1,20)
SetObjectPosition(border4,0,0,4.5)
SetObjectRotation(border4,0,0,90)
FixObjectToObject(border4,land)

plane = CreateObjectPlane(100,100)
SetObjectRotation(plane,90,0,0)
SetObjectColor(plane,100,100,100,255)
SetObjectPosition(plane,0,-.01,0)

for x=-mapsize/2 to mapsize/2
	for z=-mapsize/2 to mapsize/2
		
		map[x+mapsize/2,z+mapsize/2].id# = CreateObjectPlane(1,1)
		SetObjectRotation(map[x+mapsize/2,z+mapsize/2].id#,90,0,0)
		SetObjectColor(map[x+mapsize/2,z+mapsize/2].id#,0,random(200,255),0,255)
		SetObjectPosition(map[x+mapsize/2,z+mapsize/2].id#,x*1,0,z*1)
		FixObjectToObject(map[x+mapsize/2,z+mapsize/2].id#,land)


	next
next



RotateObjectLocalY(land,45)
planex#=0
planez#=0

do
	
	if GetRawKeyState(37) then dec planex#,.01
	if GetRawKeyState(39) then inc planex#,.01
	if GetRawKeyState(38) then dec planez#,.01
	if GetRawKeyState(40) then inc planez#,.01
	
	
	repositionmap(planex#,planez#)
	
    Print( ScreenFPS() )
    Sync()
loop

function repositionmap(offsetx#,offsetz#)

	for x=-mapsize/2 to mapsize/2
		for z=-mapsize/2 to mapsize/2
			xx# = getobjectx	(map[x+mapsize/2,z+mapsize/2].id#)
			zz# = getobjectz	(map[x+mapsize/2,z+mapsize/2].id#)
			
			
			if xx#>=-4.5 and xx#<=4.5 and zz#>=-4.5 and zz#<=4.5
				SetObjectVisible(map[ 		x+mapsize/2,z+mapsize/2].id#,1)
			else
				SetObjectVisible(map[ 		x+mapsize/2,z+mapsize/2].id#,0)
			endif
			SetObjectPosition(map[x+mapsize/2,z+mapsize/2].id#,offsetx#+x*1,0,offsetz#+z*1)
		next
	next
endfunction
