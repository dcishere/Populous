// Project: populous
// Created: 2019-01-01
         
// show all errors
SetErrorMode(2)
 
#constant screenwidth=1024
#constant screenheight=768
#constant fullscreen=0
#constant screenrate=0
// set window properties
SetWindowTitle( "populous" )
SetWindowSize( screenwidth, screenheight, fullscreen )
SetWindowAllowResize( 1 ) // allow the user to resize the window
         
// set display properties
SetVirtualResolution( screenwidth, screenheight ) // doesn't have to match the window
SetOrientationAllowed( 1, 1, 1, 1 ) // allow both portrait and landscape on mobile devices
SetSyncRate( screenrate, 0 ) // 30fps instead of 60 to save battery
SetScissor( 0,0,0,0 ) // use the maximum available screen space, no black borders
UseNewDefaultFonts( 1 ) // since version 2.0.22 we can use nicer default fonts
Create3DPhysicsWorld()  
   
   
////////////////////////////////////////////////////
/// Setup the Constants      
#constant KEY_ENTER        13
#constant KEY_NUMPAD_0     96
#constant KEY_NUMPAD_1     97
#constant KEY_NUMPAD_2     98
#constant KEY_NUMPAD_3     99
#constant KEY_NUMPAD_4     100
#constant KEY_NUMPAD_5     101
#constant KEY_NUMPAD_6     102
#constant KEY_NUMPAD_7     103
#constant KEY_NUMPAD_8     104
#constant KEY_NUMPAD_9     105
#constant sizex=18 // change this to extend the map
#constant sizez=18 // change this to exend the map
#constant worldsizex=512
#constant worldsizez=512
#constant scale#=5
#constant maxTerrainHeight# 50
////////////////////////////////////////////////////
/// Setup the Globals / Variables
    
global angx#, angy#,startx#,starty#,camerax#,cameray#,cameraz#,framespr
 
// start in the middle of the worldsize
 
global worldpositionx#=256
global worldpositionz#=256
 
//global heli, tank,heliblades,soldiers as integer[5]
global team1 as _side[]
global vertexnumber, landhitx, landhitz,land
global textimages as integer[10]
   
       
////////////////////////////////////////////////////
/// Setup the Types
type _worldmap
    heights#
    color
endtype
  
type _side
    ID as integer
    bladesID as integer
    imgID as integer
    bladesImgID as integer
    sideType as String
    xDir as float
    zDir as float
    height as float
endtype
  
global worldmap as _worldmap[worldsizex,worldsizez]
type _map
    id
    x#
//    height#
    z#
    colorred
    colorgreen
    colorblue
    texture
endtype
    
type point
    x           as float
    y           as float
    z           as float
endtype
        
global map as _map[sizex,sizez]
global castleObj   
   
////////////////////////////////////////////////////
/// Initialise and Build the worlds
startx#=screenwidth/2
starty#=screenheight/2
   
spr = buildworldsprite()
SetObjectRotation(spr,0,45,0)
  
setupcamera()
      
setupskyandworld()
     
buildworld()
   
prepareheights()
        
setupobjects()       
   
// SetSpriteVisible(framespr,0)
   
do
     
    SetObjectPosition(spr,-25,30,-10)
//    SetSpriteActive(frameSpr,0) 
       
    get_land_hit()
       
    checkkeypresses(landhitx,landhitz)
       
    moveenemies()
       
    SetCameraPosition(1,camerax#,cameray#,cameraz#)
    Print( ScreenFPS() )
  //  SetSpriteActive(frameSpr,1) 
    Sync()
loop
  
function buildworldsprite()
    mapobject = CreateObjectBox(25,.1,25)
    img= LoadImage("\media\map.png")
    SetObjectImage(mapobject,img,0)
    imgmem = CreateMemblockFromImage(img)
    imgwidth = GetMemblockInt(imgmem,0)
    for x=0 to worldsizex-1
        for z=0 to worldsizez-1
            worldmap[x,z].heights#=0
  
//    offset = (12+((z * 512) + x) * 4)           
            //offset=12 + ((z * 512) + x) * 4
  //          r= GetMemblockByte(imgmem,offset)
    //        g= GetMemblockByte(imgmem,offset+1)
      //      b= GetMemblockByte(imgmem,offset+2)
             
            if x<worldsizex/2 and z<worldsizez/2
                r=0
                b=0
                if g=0 
                    g=200
                else
                    if g=200  
                        g=150
                    else
                        if g=150 then g=200
                    endif
                endif
                 
             
 
 
            endif
 
            if x>worldsizex/2 and z<worldsizez/2
                r=200
                g=200
                b=0
            endif
             
             
            if x<worldsizex/2 and z>worldsizez/2
                r=200
                g=200
                b=200
            endif
             
            if x>worldsizex/2 and z>worldsizez/2
                r=200
                g=0
                b=0
            endif
             
             
             
//           if rand=5
//              r=139
//              g=69
//              b=19
//          endif
 
 
 
             
             
              
            worldmap[x,z].color=MakeColor(r,g,b)
//            h=g/100
  //          worldmap[x,z].heights#=h
  
  
        next
    next
    DeleteMemblock(imgmem)
              
//  SetSpriteSize(mapsprite,200,200)
//  SetSpriteAngle(mapsprite,70)
//  SetSpriteDepth(mapsprite,99)
endfunction mapobject
  
function moveenemies()
    //moveObjects(heli,-.005,0,10):RotateObjectGlobalY(heliBlades,.35)
    //moveObjects(tank,0,-0.005,2)
    for num=0 to team1.length 
        Obj=team1[num].ID
  
        moveObjects(team1[num].ID,team1[num].xDir,team1[num].zDir,team1[num].height)
        if team1[num].sideType="Chopper" then RotateObjectLocalY(team1[num].bladesID,.5)
    next num
endfunction
   
function checkkeypresses(x,z)
        //if GetRawKeyState(49) // Press 1 to rotate
        //RotateObjectLocalY(land,.05)
    //endif
        
        
        
    if GetRawMouseLeftState() //and GetSpriteHit(GetPointerX ( ), GetPointerY ( ) )=0
        flag=1
        if x<1 or x>sizex-1 then flag=0
        if z<1 or z>sizez-1 then flag=0
        if flag=1
            inc worldmap[x,z].heights#,.01
            SetObjectPosition(map[x,z].id,map[x,z].x#,worldmap[x,z].heights#,map[x,z].z#)
            changeverts(x,z,.01)
            Delete3DPhysicsBody(map[x,z].id) 
            Create3DPhysicsStaticBody(map[x,z].id)   
        endif
    endif
       
       
    if GetRawMouseRightState() //and GetSpriteHit(GetPointerX ( ), GetPointerY ( ) )=0
        flag=1
        if x<1 or x>sizex-1 then flag=0
        if z<1 or z>sizez-1 then flag=0
        if flag=1 
            if worldmap[x,z].heights#>0
                dec worldmap[x,z].heights#,.01
                SetObjectPosition(map[x,z].id,map[x,z].x#,worldmap[x,z].heights#,map[x,z].z#)
                changeverts(x,z,-.01)
                Delete3DPhysicsBody(map[x,z].id) 
                Create3DPhysicsStaticBody(map[x,z].id)
            endif
        endif
    endif
           
    if GetRawkeypressed (KEY_ENTER) 
        flag=1
        if x<1 or x>sizex-1 then flag=0
        if z<1 or z>sizez-1 then flag=0
        if flag=1 
            //if map[x,z].height#>0
                dec worldmap[x,z].heights#,10
                SetObjectPosition(map[x,z].id,map[x,z].x#,worldmap[x,z].heights#,map[x,z].z#)
                changeverts(x,z,-10.01)
                Delete3DPhysicsBody(map[x,z].id) 
                Create3DPhysicsStaticBody(map[x,z].id)
            //endif   
            //SetObjectColor(map[x,z].id,GetObjectColorRed(map[x,z].id)-50,GetObjectColorGreen(map[x,z].id)-50,GetObjectColorBlue(map[x,z].id)-50,255)  
            //SetObjectColor(map[x+1,z+1].id,GetObjectColorRed(map[x+1,z+1].id)-50,GetObjectColorGreen(map[x+1,z+1].id)-50,GetObjectColorBlue(map[x+1,z+1].id)-50,255)  
            //SetObjectColor(map[x-1,z+1].id,GetObjectColorRed(map[x-1,z+1].id)-50,GetObjectColorGreen(map[x-1,z+1].id)-50,GetObjectColorBlue(map[x-1,z+1].id)-50,255)  
            //SetObjectColor(map[x-1,z-1].id,GetObjectColorRed(map[x-1,z-1].id)-50,GetObjectColorGreen(map[x-1,z-1].id)-50,GetObjectColorBlue(map[x-1,z-1].id)-50,255)  
            //SetObjectColor(map[x+1,z].id,GetObjectColorRed(map[x+1,z].id)-50,GetObjectColorGreen(map[x+1,z].id)-50,GetObjectColorBlue(map[x+1,z].id)-50,255)  
            //SetObjectColor(map[x-1,z].id,GetObjectColorRed(map[x-1,z].id)-50,GetObjectColorGreen(map[x-1,z].id)-50,GetObjectColorBlue(map[x-1,z].id)-50,255)  
            //SetObjectColor(map[x,z+1].id,GetObjectColorRed(map[x,z+1].id)-50,GetObjectColorGreen(map[x,z+1].id)-50,GetObjectColorBlue(map[x,z+1].id)-50,255)  
            //SetObjectColor(map[x,z-1].id,GetObjectColorRed(map[x,z-1].id)-50,GetObjectColorGreen(map[x,z-1].id)-50,GetObjectColorBlue(map[x,z-1].id)-50,255)  
            SetObjectColor(map[x,z].id,100,100,100,255):SetObjectImage(map[x,z].id,textImages[1],0)  
            SetObjectColor(map[x+1,z+1].id,100,100,100,255):SetObjectImage(map[x+1,z+1].id,textImages[1],0) 
            SetObjectColor(map[x-1,z+1].id,100,100,100,255):SetObjectImage(map[x-1,z+1].id,textImages[1],0) 
            SetObjectColor(map[x-1,z-1].id,100,100,100,255):SetObjectImage(map[x-1,z-1].id,textImages[1],0) 
            SetObjectColor(map[x+1,z].id,100,100,100,255):SetObjectImage(map[x+1,z].id,textImages[1],0) 
            SetObjectColor(map[x-1,z].id,100,100,100,255):SetObjectImage(map[x-1,z].id,textImages[1],0) 
            SetObjectColor(map[x,z+1].id,100,100,100,255):SetObjectImage(map[x,z+1].id,textImages[1],0) 
            SetObjectColor(map[x,z-1].id,100,100,100,255):SetObjectImage(map[x,z-1].id,textImages[1],0) 
                  
        endif
              
    endif
       
/*   
    if GetRawKeyState(KEY_NUMPAD_4) then movemap(-0.05,0)
    if GetRawKeyState(KEY_NUMPAD_6) then movemap(0.05,0)
    if GetRawKeyState(KEY_NUMPAD_8) then movemap(0,0.05)
    if GetRawKeyState(KEY_NUMPAD_2) then movemap(0,-0.05)
    
    if GetRawKeyState(KEY_NUMPAD_7) then movemap(-0.05,0.05)
    if GetRawKeyState(KEY_NUMPAD_9) then movemap(0.05,0.05)
    if GetRawKeyState(KEY_NUMPAD_3) then movemap(0.05,-0.05)
    if GetRawKeyState(KEY_NUMPAD_1) then movemap(-0.05,-0.05)
    
*/
    
   if GetRawKeyState(KEY_NUMPAD_4) 
        movemap2(0.05,0)
        for num = 0 to team1.length
            moveObjectsWithMap(team1[num].ID,0.05,0)
        next num    
    endif
    if GetRawKeyState(KEY_NUMPAD_6) 
        movemap2(-0.05,0)
        for num = 0 to team1.length
            moveObjectsWithMap(team1[num].ID,-0.05,0)
        next num    
    endif
    if GetRawKeyState(KEY_NUMPAD_8) 
        movemap2(0,-0.05)
        for num = 0 to team1.length
            moveObjectsWithMap(team1[num].ID,0,-0.05)
        next num    
    endif
    if GetRawKeyState(KEY_NUMPAD_2) 
        movemap2(0,0.05)
        for num = 0 to team1.length
            moveObjectsWithMap(team1[num].ID,0,0.05)
        next num    
    endif
      
    if GetRawKeyState(KEY_NUMPAD_7) 
        movemap2(0.05,-0.05)
        for num = 0 to team1.length
            moveObjectsWithMap(team1[num].ID,0.05,-0.05)
        next num    
    endif
    if GetRawKeyState(KEY_NUMPAD_9) 
        movemap2(-0.05,-0.05)
        for num = 0 to team1.length
            moveObjectsWithMap(team1[num].ID,-0.05,-0.05)
        next num    
    endif
     
    if GetRawKeyState(KEY_NUMPAD_3) 
        movemap2(-0.05,0.05)
        for num = 0 to team1.length
            moveObjectsWithMap(team1[num].ID,-0.05,0.05)
        next num    
    endif
    if GetRawKeyState(KEY_NUMPAD_1) 
        movemap2(0.05,0.05)
        for num = 0 to team1.length
            moveObjectsWithMap(team1[num].ID,0.05,0.05)
        next num    
    endif
endfunction   
function moveObjectsWithMap(Obj,x as float,z as float)
    SetObjectPosition(Obj,getObjectX(Obj)+x,getobjectY(Obj),getObjectZ(Obj)+z)
endfunction
   
function get_land_hit()
    unit_x#=Get3DVectorXFromScreen(getpointerx(),getpointery())
    unit_y#=Get3DVectorYFromScreen(getpointerx(),getpointery())
    unit_z#=Get3DVectorZFromScreen(getpointerx(),getpointery()) 
    // calculate the start of the ray cast, which is the unit vector + the camera position
        start_x# = unit_x# + GetCameraX(1)
        start_y# = unit_y# + GetCameraY(1)
        start_z# = unit_z# + GetCameraZ(1)
               
        // calculate the end of the vector, which is the unit vector multiplied by the length of the ray cast and then add the camera position to it
        end_x# = 1000*unit_x# + GetCameraX(1)
        end_y# = 1000*unit_y# + GetCameraY(1)
        end_z# = 1000*unit_z# + GetCameraZ(1)  
        // determine which object has been hit
        object_hit = ObjectRayCast(0,start_x#,start_y#,start_z#,end_x#,end_y#,end_z#)
       
            
        // added by Fubarpk 
        if object_hit <> 0
            for xx=-sizex/2 to sizex/2 step 1
                for zz=-sizez/2 to sizez/2 step 1.0
                    if object_hit=map[xx+(sizex/2),zz+(sizez/2)].id
                        landhitx=xx+sizex/2
                        landhitz=zz+sizez/2
                            
                    endif
                next zz
            next xx 
        endif
 endfunction
   
function buildworld()
    land = CreateObjectBox(.01,.01,.01)
    SetObjectVisible(land,0)
   
/* 
edge1 = CreateObjectBox(5,100,100)
SetObjectRotation(edge1,0,0,0)
SetObjectPosition(edge1,(sizex*scale#)/2,7,0)
FixObjectToObject(edge1,land)
SetObjectColor(edge1,0,0,0,0)
  
edge1 = CreateObjectBox(10,10,100)
SetObjectRotation(edge1,0,0,0)
SetObjectPosition(edge1,-(sizex*scale#)/2,7,0)
FixObjectToObject(edge1,land)
SetObjectColor(edge1,0,0,0,0)
  
  
edge1 = CreateObjectBox(100,100,5)
SetObjectRotation(edge1,0,0,0)
SetObjectPosition(edge1,0,7,(sizex*scale#)/2)
FixObjectToObject(edge1,land)
SetObjectColor(edge1,0,0,0,0)
  
edge1 = CreateObjectBox(100,10,10)
SetObjectRotation(edge1,0,0,0)
SetObjectPosition(edge1,0,7,-(sizex*scale#)/2)
FixObjectToObject(edge1,land)
SetObjectColor(edge1,0,0,0,0)
 */
  
   
   
    colorgreen=150
    for x=-sizex/2 to sizex/2 step 1.0
        for z=-sizez/2 to sizez/2 step 1.0
            map[x+sizex/2,z+sizez/2].id = CreateObjectBox(scale#,scale#,scale#)
            map[x+sizex/2,z+sizez/2].x# = x * GetObjectSizeMaxX(map[x+sizex/2,z+sizez/2].id)*2 // Remove the * 2 to join the cubes together
            map[x+sizex/2,z+sizez/2].z# = z * GetObjectSizeMaxZ(map[x+sizex/2,z+sizez/2].id)*2 // Remove the * 2 to join the cubes together
  
  
        //map[x,z].colorgreen = random(150,200)
        //SetObjectImage(map[x,z].id,textimages[0],0)
            if colorgreen=150
                colorgreen=200
            else
                colorgreen=150
            endif
              
            map[x+sizex/2,z+sizez/2].colorblue = worldmap[floor(worldpositionx#+x) ,floor(worldpositionz#+z)].color >> 16 && 0xff
            map[x+sizex/2,z+sizez/2].colorgreen = worldmap[floor(worldpositionx#+x),floor(worldpositionz#+z)].color >> 8 && 0xff
            map[x+sizex/2,z+sizez/2].colorred = worldmap[floor(worldpositionx#+x)  ,floor(worldpositionz#+z)].color && 0xff
              
              
              
            SetObjectImage(map[x+sizex/2,z+sizez/2].id,textimages[0],0)
            SetObjectReceiveShadow(map[x+sizex/2,z+sizez/2].id,3) 
            Create3DPhysicsStaticBody(map[x+sizex/2,z+sizez/2].id)
                 
            SetObjectColor(map[x+sizex/2,z+sizez/2].id,map[x+sizex/2,z+sizez/2].colorred,map[x+sizex/2,z+sizez/2].colorgreen,map[x+sizex/2,z+sizez/2].colorblue,255)
              
            SetObjectPosition(map[x+sizex/2,z+sizez/2].id,map[x+sizex/2,z+sizez/2].x#,worldmap[x+sizex/2,z+sizez/2].heights#,map[x+sizex/2,z+sizez/2].z#)
            FixObjectToObject(map[x+sizex/2,z+sizez/2].id,land)
                      
        next
    next
 //   addatower(sizex/2, sizez/2) // add a tower in the centre of map just for time being
      
    //RotateObjectLocalY(land,134)
//RotateObjectLocalX(land,-70)
endfunction
  
   
function addatower(x,z)
    for xx=x-1 to x+1
        for zz=z-1 to z+1
            worldmap[xx,zz].heights#=5 // high rise it
              
            map[xx,zz].colorred =255 
            map[xx,zz].colorgreen =255
            map[xx,zz].colorblue=255
            SetObjectColor(map[xx,zz].id,map[xx,zz].colorred,map[xx,zz].colorgreen,map[xx,zz].colorblue,255)
            SetObjectPosition(map[x+sizex/2,z+sizez/2].id,map[x+sizex/2,z+sizez/2].x#,worldmap[x+sizex/2,z+sizez/2].heights#,map[x+sizex/2,z+sizez/2].z#)
            changeverts(xx,zz,worldmap[xx,zz].heights#)
             
        next
    next
      
endfunction
    
function movemap(xdir#,zdir#)
 
    for x=-sizex/2 to sizex/2 step 1.0
        for z=-sizez/2 to sizez/2 step 1.0
            inc map[x+sizex/2,z+sizez/2].x#, xdir# 
            inc map[x+sizex/2,z+sizez/2].z#, zdir#
      
  // roll
            if map[x+sizex/2,z+sizez/2].x#<-sizex*2.75 then map[x+sizex/2,z+sizez/2].x# = sizex/2 * scale#
            if map[x+sizex/2,z+sizez/2].x#>sizex*2.75 then map[x+sizex/2,z+sizez/2].x# = -sizex/2 * scale#
    
    
            if map[x+sizex/2,z+sizez/2].z#<-sizez*2.75 then map[x+sizex/2,z+sizez/2].z# = sizez/2 * scale#
            if map[x+sizex/2,z+sizez/2].z#>sizez*2.75 then map[x+sizex/2,z+sizez/2].z# = -sizez/2 * scale#
    
    
            map[x+sizex/2,z+sizez/2].colorblue =  worldmap[floor(worldpositionx#)+x,floor(worldpositionz#)+z].color >> 16 && 0xff
            map[x+sizex/2,z+sizez/2].colorgreen = worldmap[floor(worldpositionx#)+x,floor(worldpositionz#)+z].color >> 8 && 0xff
            map[x+sizex/2,z+sizez/2].colorred =   worldmap[floor(worldpositionx#)+x,floor(worldpositionz#)+z].color && 0xff
    
      
            SetObjectPosition(map[x+sizex/2,z+sizez/2].id,map[x+sizex/2,z+sizez/2].x#,worldmap[x+sizex/2,z+sizez/2].heights#,map[x+sizex/2,z+sizez/2].z#)
            SetObjectColor(map[x+sizex/2,z+sizez/2].id,map[x+sizex/2,z+sizez/2].colorred,map[x+sizex/2,z+sizez/2].colorgreen,map[x+sizex/2,z+sizez/2].colorblue,255)
              
    next
  
next
        
endfunction
 
function movemap2(xdir#,zdir#)
    SetObjectPosition(castleObj,getObjectX(castleObj)+xDir#,getObjectY(castleObj),getObjectZ(castleObj)+zdir#)
 
    for x=-sizex/2 to sizex/2 step 1.0
        for z=-sizez/2 to sizez/2 step 1.0
            map[x+sizex/2,z+sizez/2].x#=map[x+sizex/2,z+sizez/2].x#+ xdir# 
            map[x+sizex/2,z+sizez/2].z#=map[x+sizex/2,z+sizez/2].z#+ zdir#
       
  // roll
            if map[x+sizex/2,z+sizez/2].x#<-sizex*2.5 then map[x+sizex/2,z+sizez/2].x# = sizex/2 * scale#
            if map[x+sizex/2,z+sizez/2].x#>sizex*2.5 then map[x+sizex/2,z+sizez/2].x# = -sizex/2 * scale#
     
     
            if map[x+sizex/2,z+sizez/2].z#<-sizez*2.5 then map[x+sizex/2,z+sizez/2].z# = sizez/2 * scale#
            if map[x+sizex/2,z+sizez/2].z#>sizez*2.5 then map[x+sizex/2,z+sizez/2].z# = -sizez/2 * scale#
     
     
     
       
            SetObjectPosition(map[x+sizex/2,z+sizez/2].id,map[x+sizex/2,z+sizez/2].x#,worldmap[x+sizex/2,z+sizez/2].heights#,map[x+sizex/2,z+sizez/2].z#)
               
    next
   
next
endfunction   
function movecamera()
    if GetRawKeyState(32)
    fDiffX# = (GetPointerX() - startx#)/4.0
    fDiffY# = (GetPointerY() - starty#)/4.0
    newX# = angx# + fDiffY#
    if ( newX# > 89 ) then newX# = 89
    if ( newX# < -89 ) then newX# = -89
    SetCameraRotation(1, newX#, angy# + fDiffX#, 0 )
    endif
endfunction
         
function prepareheights()
    for x=2 to sizex-1
        for z=2 to sizez-1
              
            changeverts(x,z,worldmap[x,z].heights#)
        next
    next
endfunction
         
function changeverts(x,z,slope#)
            
            CreateMemblockFromObjectMesh(2,map[x+1,z-1].id,1) // bottom right corner
            CreateMemblockFromObjectMesh(4,map[x+1,z+1].id,1) // top right corner
            CreateMemblockFromObjectMesh(5,map[x-1,z+1].id,1) // top left corner
            CreateMemblockFromObjectMesh(6,map[x-1,z-1].id,1) // bottom left corner
          
            CreateMemblockFromObjectMesh(3,map[x+1,z].id,1) // right edges
        
            CreateMemblockFromObjectMesh(7,map[x-1,z].id,1) // left cube edges
           CreateMemblockFromObjectMesh(8,map[x,z-1].id,1) // bottom cube edges
           CreateMemblockFromObjectMesh(9,map[x,z+1].id,1) // top cube edges
        
                    
    for i=0 to 23
                
// bottom rightcorner
        if i=8 then SetMeshMemblockVertexPosition(2,i,GetMeshMemblockVertexX(2,i),GetMeshMemblockVertexY(2,i)+slope#,GetMeshMemblockVertexZ(2,i))
        if i=16 then SetMeshMemblockVertexPosition(2,i,GetMeshMemblockVertexX(2,i),GetMeshMemblockVertexY(2,i)+slope#,GetMeshMemblockVertexZ(2,i))
        if i=14 then SetMeshMemblockVertexPosition(2,i,GetMeshMemblockVertexX(2,i),GetMeshMemblockVertexY(2,i)+slope#,GetMeshMemblockVertexZ(2,i))
        
// top rightcorner
        if i=9 then SetMeshMemblockVertexPosition(4,i,GetMeshMemblockVertexX(4,i),GetMeshMemblockVertexY(4,i)+slope#,GetMeshMemblockVertexZ(4,i))
        if i=0 then SetMeshMemblockVertexPosition(4,i,GetMeshMemblockVertexX(4,i),GetMeshMemblockVertexY(4,i)+slope#,GetMeshMemblockVertexZ(4,i))
        if i=18 then SetMeshMemblockVertexPosition(4,i,GetMeshMemblockVertexX(4,i),GetMeshMemblockVertexY(4,i)+slope#,GetMeshMemblockVertexZ(4,i))
        
// top leftcorner
        if i=11 then SetMeshMemblockVertexPosition(5,i,GetMeshMemblockVertexX(5,i),GetMeshMemblockVertexY(5,i)+slope#,GetMeshMemblockVertexZ(5,i))
        if i=2 then SetMeshMemblockVertexPosition(5,i,GetMeshMemblockVertexX(5,i),GetMeshMemblockVertexY(5,i)+slope#,GetMeshMemblockVertexZ(5,i))
       if i=4 then SetMeshMemblockVertexPosition(5,i,GetMeshMemblockVertexX(5,i),GetMeshMemblockVertexY(5,i)+slope#,GetMeshMemblockVertexZ(5,i))
         
        
// tbottom leftcorner
        if i=10 then SetMeshMemblockVertexPosition(6,i,GetMeshMemblockVertexX(6,i),GetMeshMemblockVertexY(6,i)+slope#,GetMeshMemblockVertexZ(6,i))
        if i=6 then SetMeshMemblockVertexPosition(6,i,GetMeshMemblockVertexX(6,i),GetMeshMemblockVertexY(6,i)+slope#,GetMeshMemblockVertexZ(6,i))
        if i=12 then SetMeshMemblockVertexPosition(6,i,GetMeshMemblockVertexX(6,i),GetMeshMemblockVertexY(6,i)+slope#,GetMeshMemblockVertexZ(6,i))
        
        
// right cube
        if i=8 then SetMeshMemblockVertexPosition(3,i,GetMeshMemblockVertexX(3,i),GetMeshMemblockVertexY(3,i)+slope#,GetMeshMemblockVertexZ(3,i))
        if i=9 then SetMeshMemblockVertexPosition(3,i,GetMeshMemblockVertexX(3,i),GetMeshMemblockVertexY(3,i)+slope#,GetMeshMemblockVertexZ(3,i))
        if i=16 then SetMeshMemblockVertexPosition(3,i,GetMeshMemblockVertexX(3,i),GetMeshMemblockVertexY(3,i)+slope#,GetMeshMemblockVertexZ(3,i))
        if i=18 then SetMeshMemblockVertexPosition(3,i,GetMeshMemblockVertexX(3,i),GetMeshMemblockVertexY(3,i)+slope#,GetMeshMemblockVertexZ(3,i))
        if i=0 then SetMeshMemblockVertexPosition(3,i,GetMeshMemblockVertexX(3,i),GetMeshMemblockVertexY(3,i)+slope#,GetMeshMemblockVertexZ(3,i))
        if i=14 then SetMeshMemblockVertexPosition(3,i,GetMeshMemblockVertexX(3,i),GetMeshMemblockVertexY(3,i)+slope#,GetMeshMemblockVertexZ(3,i))
        
// left cube
        if i=10 then SetMeshMemblockVertexPosition(7,i,GetMeshMemblockVertexX(7,i),GetMeshMemblockVertexY(7,i)+slope#,GetMeshMemblockVertexZ(7,i))
        if i=11 then SetMeshMemblockVertexPosition(7,i,GetMeshMemblockVertexX(7,i),GetMeshMemblockVertexY(7,i)+slope#,GetMeshMemblockVertexZ(7,i))
        if i=4 then SetMeshMemblockVertexPosition(7,i,GetMeshMemblockVertexX(7,i),GetMeshMemblockVertexY(7,i)+slope#,GetMeshMemblockVertexZ(7,i))
        if i=6 then SetMeshMemblockVertexPosition(7,i,GetMeshMemblockVertexX(7,i),GetMeshMemblockVertexY(7,i)+slope#,GetMeshMemblockVertexZ(7,i))
        if i=2 then SetMeshMemblockVertexPosition(7,i,GetMeshMemblockVertexX(7,i),GetMeshMemblockVertexY(7,i)+slope#,GetMeshMemblockVertexZ(7,i))
        if i=12 then SetMeshMemblockVertexPosition(7,i,GetMeshMemblockVertexX(7,i),GetMeshMemblockVertexY(7,i)+slope#,GetMeshMemblockVertexZ(7,i))
               
// bottom cube
        if i=8 then SetMeshMemblockVertexPosition(8,i,GetMeshMemblockVertexX(8,i),GetMeshMemblockVertexY(8,i)+slope#,GetMeshMemblockVertexZ(8,i))
        if i=10 then SetMeshMemblockVertexPosition(8,i,GetMeshMemblockVertexX(8,i),GetMeshMemblockVertexY(8,i)+slope#,GetMeshMemblockVertexZ(8,i))
        if i=6 then SetMeshMemblockVertexPosition(8,i,GetMeshMemblockVertexX(8,i),GetMeshMemblockVertexY(8,i)+slope#,GetMeshMemblockVertexZ(8,i))
        if i=12 then SetMeshMemblockVertexPosition(8,i,GetMeshMemblockVertexX(8,i),GetMeshMemblockVertexY(8,i)+slope#,GetMeshMemblockVertexZ(8,i))
        if i=14 then SetMeshMemblockVertexPosition(8,i,GetMeshMemblockVertexX(8,i),GetMeshMemblockVertexY(8,i)+slope#,GetMeshMemblockVertexZ(8,i))
        if i=16 then SetMeshMemblockVertexPosition(8,i,GetMeshMemblockVertexX(8,i),GetMeshMemblockVertexY(8,i)+slope#,GetMeshMemblockVertexZ(8,i))
        
// top cube
        if i=9 then SetMeshMemblockVertexPosition(9,i,GetMeshMemblockVertexX(9,i),GetMeshMemblockVertexY(9,i)+slope#,GetMeshMemblockVertexZ(9,i))
        if i=11 then SetMeshMemblockVertexPosition(9,i,GetMeshMemblockVertexX(9,i),GetMeshMemblockVertexY(9,i)+slope#,GetMeshMemblockVertexZ(9,i))
        if i=0 then SetMeshMemblockVertexPosition(9,i,GetMeshMemblockVertexX(9,i),GetMeshMemblockVertexY(9,i)+slope#,GetMeshMemblockVertexZ(9,i))
        if i=2 then SetMeshMemblockVertexPosition(9,i,GetMeshMemblockVertexX(9,i),GetMeshMemblockVertexY(9,i)+slope#,GetMeshMemblockVertexZ(9,i))
        if i=4 then SetMeshMemblockVertexPosition(9,i,GetMeshMemblockVertexX(9,i),GetMeshMemblockVertexY(9,i)+slope#,GetMeshMemblockVertexZ(9,i))
        if i=18 then SetMeshMemblockVertexPosition(9,i,GetMeshMemblockVertexX(9,i),GetMeshMemblockVertexY(9,i)+slope#,GetMeshMemblockVertexZ(9,i))
        
    next
            
    SetObjectMeshFromMemblock(map[x+1,z-1].id,1,2)   
    SetObjectMeshFromMemblock(map[x+1,z].id,1,3)   
    SetObjectMeshFromMemblock(map[x+1,z+1].id,1,4)   
    SetObjectMeshFromMemblock(map[x-1,z+1].id,1,5)   
    SetObjectMeshFromMemblock(map[x-1,z-1].id,1,6)   
    SetObjectMeshFromMemblock(map[x-1,z].id,1,7)   
    SetObjectMeshFromMemblock(map[x,z-1].id,1,8)   
    SetObjectMeshFromMemblock(map[x,z+1].id,1,9)   
        
        
        
        
        
        
    DeleteMemblock(2)
    DeleteMemblock(3)
    DeleteMemblock(4)
    DeleteMemblock(5)
    DeleteMemblock(6)
    DeleteMemblock(7)
    DeleteMemblock(8)
    DeleteMemblock(9)
         
         
endfunction
      
// Function to create a texture
//
// Inputs - Sizex - size of the texture to create - width
//          Sizey - size of the texture to create - height
//          Color - is the main color of the image
//          Denisity - is a the depth of the texture - the lower the value, the more detail. higher value = no detail
// 
// Returns the image for the resulting texture
//
// EG. CreateTexture ( 100, 100,  makecolor(0,0,255), 100)
//          This could create a DEEP water effect texture?
        
function createtexture(sizex# as float, sizey# as float, color, density as integer)
        
            
    swap()
    drawbox(0,0,sizex#, sizey#, color, color,color,color, 1)
    render()
    img = getimage(0,0,sizex#, sizey#)
            
    memblockid = CreateMemblockFromImage (img)
    imgwidth = GetMemblockInt(memblockid, 0)
    imgheight = GetMemblockInt(memblockid, 4)
            
            
        size=GetMemblockSize(memblockid)
        
        for offset=12 to size-4 step 4
              
            r=GetMemblockByte(memblockid, offset)
            g=GetMemblockByte(memblockid, offset+1)
            b=GetMemblockByte(memblockid, offset+2)
            a=GetMemblockByte(memblockid, offset+3)
                    
                
            strength=random(1,density)
        
            SetMemblockByte (memblockid, offset, r-strength)
            SetMemblockByte (memblockid, offset+1, g-strength)
            SetMemblockByte (memblockid, offset+2, b-strength )
            SetMemblockByte (memblockid, offset+3, a-strength)
                     
                
    next
            
    deleteimage (img)
            
    img = CreateImageFromMemblock(memblockid)
    DeleteMemblock(memblockid)
        
        
endfunction img
    
function moveObjects(Obj,x as float,z as float,height as float)
choice=random(1,2)
//use this code for objects to go over terrain
///////////////////////////////////////////////////////////////////////////////////////////////    
/*
if choice=1    
    SetObjectPosition(Obj,getObjectX(Obj),getobjectY(Obj)+maxTerrainHeight#,getObjectZ(Obj))
    
    DirVec=getForwardDirectionVector(Obj)
    hitObj=ObjectRayCast(0,getobjectx(obj)+GetVector3X(DirVec),getobjecty(obj)-(maxTerrainHeight#+50),getobjectz(obj)+GetVector3X(DirVec),getobjectx(obj)+GetVector3X(DirVec),getobjecty(obj),getobjectz(obj)+GetVector3Z(DirVec))
    if hitObj>0
        SetObjectPosition(Obj,getObjectX(Obj)+x,getobjectY(hitObj)+height,getObjectZ(Obj)+z)
    else
        SetObjectPosition(Obj,getObjectX(Obj)+x,height,getObjectZ(Obj)+z)
            
    endif
endif 
*/
//////////////////////////////////////////////////////    
//use this code for objects to go around terrain    
//////////////////////////////////////////////////////
/*
if choice=2
    oldx#=getObjectX(obj):oldy#=getObjecty(obj):oldz#=getObjectz(obj)
    SetObjectPosition(Obj,getObjectX(Obj)+x,height,getObjectZ(Obj)+z)
            
    if ObjectSphereSlide(0,oldx#,oldy#,oldz#,getobjectx(obj),getobjecty(obj),getobjectz(obj),.005)>0
        newx2#=GetObjectRayCastSlideX(0)
        newy2#=GetObjectRayCastSlideY(0)
        newz2#=GetObjectRayCastSlideZ(0)
        Setobjectposition(obj,newx2#,newy2#,newz2#)
    endif
endif
*/
//////////////////////////////////////////////////////
    
//this code to go over and around
///////////////////////////////////////////////////////////////////////////////////////////////    
    
    SetObjectPosition(Obj,getObjectX(Obj),getobjectY(Obj)+maxTerrainHeight#,getObjectZ(Obj))
    
    DirVec=getForwardDirectionVector(Obj)
    hitObj=ObjectRayCast(0,getobjectx(obj)+GetVector3X(DirVec),getobjecty(obj)-(maxTerrainHeight#+50),getobjectz(obj)+GetVector3X(DirVec),getobjectx(obj)+GetVector3X(DirVec),getobjecty(obj),getobjectz(obj)+GetVector3Z(DirVec))
    if hitObj>0
        oldx#=getObjectX(obj):oldy#=getObjecty(obj):oldz#=getObjectz(obj)
        SetObjectPosition(Obj,getObjectX(Obj)+x,getobjectY(hitObj)+height,getObjectZ(Obj)+z)
    else
        oldx#=getObjectX(obj):oldy#=getObjecty(obj):oldz#=getObjectz(obj)
        SetObjectPosition(Obj,getObjectX(Obj)+x,height,getObjectZ(Obj)+z)    
    endif
            
    if ObjectSphereSlide(0,oldx#,oldy#,oldz#,getobjectx(obj),getobjecty(obj),getobjectz(obj),.005)>0
        newx2#=GetObjectRayCastSlideX(0)
        newy2#=GetObjectRayCastSlideY(0)
        newz2#=GetObjectRayCastSlideZ(0)
        Setobjectposition(obj,newx2#,newy2#,newz2#)
    endif
    
       
//////////////////////////////////////////////////////
    
    if getObjectX(Obj)<-(sizex*3) then SetObjectPosition(Obj,(sizex*3),getObjectY(Obj),getObjectZ(Obj))
    if getObjectX(Obj)>(sizex*3) then SetObjectPosition(Obj,-(sizex*3),getObjectY(Obj),getObjectZ(Obj))
    if getObjectZ(Obj)<-(sizez*3) then SetObjectPosition(Obj,getObjectX(Obj),getObjectY(Obj),(sizez*3))
    if getObjectZ(Obj)>(sizez*3) then SetObjectPosition(Obj,getObjectX(Obj),getObjectY(Obj),-(sizez*3))
    if getobjectx(obj)<-sizex
        SetObjectVisible(obj,0)
    else
        SetObjectVisible(obj,1)
    endif
     
    if getobjectx(obj)>sizex
        SetObjectVisible(obj,0)
    else
        SetObjectVisible(obj,1)
    endif
     
    if getobjectz(obj)<-sizez
        SetObjectVisible(obj,0)
    else
        SetObjectVisible(obj,1)
    endif
     
    if getobjectz(obj)>sizez
        SetObjectVisible(obj,0)
    else
        SetObjectVisible(obj,1)
    endif
         
         
         
         
endfunction
  
function getForwardDirectionVector(obj as integer)
    PositionVec= CreateVector3(GetObjectWorldX(obj),GetObjectWorldY(obj),GetObjectWorldZ(obj))
    DirBox as integer
    DirBox = CreateObjectBox( 1.0, 1.0, 1.0 )
    SetObjectPosition( DirBox, GetVector3X( PositionVec ), GetVector3Y( PositionVec ), GetVector3Z( PositionVec ) ) 
    setobjectrotation(Dirbox,GetObjectWorldAngleX(obj),GetObjectWorldAngleY(obj),GetObjectWorldAngleZ(obj))
    MoveObjectLocalZ(DirBox,-0.005)
    DirVec = CreateVector3( GetobjectWorldX(DirBox )-GetVector3X(PositionVec), GetobjectWorldY(DirBox)-GetVector3Y(PositionVec), GetobjectWorldZ(DirBox)-GetVector3Z(PositionVec))    
    DeleteObject(DirBox)
endfunction DirVec
   
   
function    CreatePoint(x as float, y as float, z as float)
    p   as point
        
    p.x = x
    p.y = y
    p.z = z
endfunction p
   
function setupskyandworld()
       
    //textimages[0]= createtexture(64,64,MakeColor(0,255,0),255)
    textimages[0]= createtexture(64,64,MakeColor(255,255,255),255)
   
    sundirection    as point
    sundirection = CreatePoint(0.2, -1, 0.2)                                    /// Setup Sun and lighting
    SetSunDirection(sundirection.x, sundirection.y, sundirection.z)
    SetAmbientColor(0x60, 0x60, 0x60)
    SetSkyBoxSkyColor(14,158,194 ) 
    SetSkyBoxHorizonSize(1,-350 ) 
    SetSkyBoxVisible(0) 
    SetSunColor(0x80, 0x80, 0x80)
    //SetSkyBoxSunVisible(1)
    
    shadowmode as integer
    shadowMode = 3 // start with cascade shadow mapping which gives the best quality
    SetShadowMappingMode( shadowMode )
    SetShadowSmoothing( 1 ) // random sampling
    SetShadowMapSize( 1024,1024 )
    SetShadowRange( -1 ) // use the full camera range
    SetShadowBias( 0.0012 ) // offset shadows slightly to avoid shadow artifacts
endfunction
   
function setupcamera()
    camerax#=0
    cameray#=50
    cameraz#=-70
    
    SetCameraRotation(1,26,0,0)
endfunction
   
 
function setupobjects()
    team as _side
 
    frameImg=LoadImage("\media\frame2.png")
    frameSpr=createSprite(frameImg) 
    SetSpriteShape(frameSPr,3) 
    //SetSpriteVisible(frameSpr,0)
    chopperObj=LoadObject("chopper.obj")
    chopperBladesObj=LoadObject("blades.obj")
    chopperImg=loadImage("chopper.png")
    chopperBladesImg=LoadImage("blades.png")
    tankObj=LoadObject("leopard2A4.obj")
    tankImg=loadImage("leopard2A4.png")
    soldierObj=LoadObject("soldier.obj")
    soldierImg=LoadImage("soldier.png")
    castleObj=LoadObject("castle.obj")
    castleImg=loadImage("castle.png")
    SetObjectImage(castleObj,castleImg,0)
    SetObjectPosition(castleObj,0,6,0)
    SetObjectScale(castleObj,10,10,10)
    RotateObjectLocalY(castleObj,45)
    Create3DPhysicsStaticBody(castleObj)
    xOffset=0:zOffset=0     
    for teams =1 to 4
        x=random2(-(sizex*3),(sizex*3)):z=random2(-(sizez*3),(sizez*3))  
        angle=random(0,360):xOffset=1:zOffset=4 
        team.ID=CloneObject(chopperObj)
        team.bladesID=CloneObject(chopperBladesObj)
        team.bladesImgID=chopperImg
        team.imgID=chopperImg
        SetObjectImage(team.ID,team.imgID,0)
        SetObjectImage(team.bladesID,team.bladesImgID,0)
        SetObjectPosition(team.ID,0,5,-10)
        SetObjectScale(team.ID,2,2,2)
        SetObjectPosition(team.bladesID,0,.6,0)
        FixObjectToObject(team.bladesID,team.ID)
        SetObjectScale(team.bladesID,5,5,5)
        SetObjectCastShadow(team.ID,1)
        SetObjectCastShadow(team.bladesID,1)
        SetObjectColor(team.id,255,0,0,255)
        SetObjectColor(team.bladesID,255,0,0,255)
        SetObjectPosition(team.ID,x+(xOffset*2),5,z-(10+zOffset))
        RotateObjectLocalY(team.ID,angle)
        vec=getForwardDirectionVector2(team.ID,.025)
        team.xDir=GetVector3X(vec)
        team.zDir=GetVector3Z(vec)
        team.height=10
        team.sideType="Chopper"
        team1.insert(team):xOffset=1:zOffset=2
     
        team.ID=cloneObject(tankObj)
        team.imgID=tankImg
        SetObjectImage(team.ID,team.imgID,0)
        SetObjectPosition(team.ID,x+(xOffset*2),2,z-(10+zOffset))
        //RotateObjectLocalY(team.ID,-90)
        RotateObjectLocalY(team.ID,angle)
        SetObjectScale(team.ID,1,1,1)
        SetObjectCastShadow(team.ID,1)
        SetObjectColor(team.id,255,0,0,255)
        vec=getForwardDirectionVector2(team.ID,.025)
        team.xDir=GetVector3X(vec)
        team.zDir=GetVector3Z(vec)
        team.height=2
        team.sideType="Tank"
        team1.insert(team):xOffset=0:zOffset=0
        for num = 0 to 5
            team.ID=CloneObject(soldierObj)
            team.imgID=soldierImg
            SetObjectImage(team.ID,team.imgID,0)
            SetObjectPosition(team.ID,x+(xOffset*2),6,z-(10+zOffset))
            //RotateObjectLocalY(team.ID,90)
            RotateObjectLocalY(team.ID,angle)
            SetObjectScale(team.ID,.6,.6,.6)
            SetObjectCastShadow(team.ID,1)
            SetObjectColor(team.id,255,0,0,255)
            vec=getForwardDirectionVector2(team.ID,.025)
            team.xDir=GetVector3X(vec)
            team.zDir=GetVector3Z(vec)
            team.height=7
            team.sideType="Soldier"
            team1.insert(team)
            inc xOffset
            if xOffset=3 
                xOffset=0:zOffset=2
            endif  
        next num
    next teams  
     
    //stuck the below in because they are being cloned
    SetObjectVisible(chopperObj,0):SetObjectCollisionMode(chopperObj,0)
    SetObjectVisible(chopperBladesObj,0):SetObjectCollisionMode(chopperBladesObj,0)
    SetObjectVisible(tankObj,0):SetObjectCollisionMode(tankObj,0)
    SetObjectVisible(soldierObj,0):SetObjectCollisionMode(soldierObj,0)
     
endfunction
    
//vec=getForwardDirectionVector2(objId,.005)
//xDir=GetVector3X(vec)
//zDir=GetVector3Z(vec)
function getForwardDirectionVector2(obj as integer,moveAmmount as float)
    PositionVec= CreateVector3(GetObjectWorldX(obj),GetObjectWorldY(obj),GetObjectWorldZ(obj))
    DirBox as integer
    DirBox = CreateObjectBox( 1.0, 1.0, 1.0 )
    SetObjectPosition( DirBox, GetVector3X( PositionVec ), GetVector3Y( PositionVec ), GetVector3Z( PositionVec ) ) 
    setobjectrotation(Dirbox,GetObjectWorldAngleX(obj),GetObjectWorldAngleY(obj),GetObjectWorldAngleZ(obj))
    MoveObjectLocalX(DirBox,-moveAmmount)
    DirVec = CreateVector3( GetobjectWorldX(DirBox )-GetVector3X(PositionVec), GetobjectWorldY(DirBox)-GetVector3Y(PositionVec), GetobjectWorldZ(DirBox)-GetVector3Z(PositionVec))    
    DeleteObject(DirBox)
endfunction DirVec
  
function getMoveAmmount(Obj,x as float,z as float)
    x#=GetObjectWorldX(Obj):y#=GetObjectWorldY(Obj):z#=GetObjectWorldZ(Obj)
    xx#=x#+x:zz#=z#+z
    vec1=CreateVector3(x#,y#,z#)
    vec2=CreateVector3(xx#,y#,zz#)
    moveAmmount#=GetVector3Distance(vec1,vec2 ) 
    DeleteVector3(vec1)
    DeleteVector3(vec2)
endfunction moveAmmount#  
  
function moveObjects2(Obj,x as float,z as float,height as float)
    x#=getobjectx(Obj)
    y#=getobjecty(Obj)
    z#=getobjectz(Obj)
    //vec=getForwardDirectionVector2(obj,moveAmmount#)
    moveAmmount#=getMoveAmmount(Obj,x,z)
    hitObj=ObjectRayCast(0,getobjectx(obj),getobjecty(obj)-(maxTerrainHeight#+50),getobjectz(obj),getobjectx(obj),getobjecty(obj),getobjectz(obj))
    if hitObj>0
        yy#=GetObjectY(hitObj)+height
    else
        yy#=getObjectY(obj)
    endif  
    setobjectposition(Obj,x#,yy#,z#)
      
      
    MoveObjectLocalX(Obj,-moveAmmount#)
    setobjectrotation(Obj,0,GetObjectWorldAngleY(obj),0)   
      
    //getting new y value in front  
    MoveObjectLocalX(Obj,-moveAmmount#)
    x2#=getobjectx(Obj)
    z2#=getobjectz(Obj)
    hitObj=ObjectRayCast(0,getobjectx(obj),getobjecty(obj)-(maxTerrainHeight#+50),getobjectz(obj),getobjectx(obj),getobjecty(obj),getobjectz(obj))
    if hitObj>0
        y2#=GetObjectY(hitObj)+height
    else
        y2#=getObjecty(obj)
    endif 
    moveobjectlocalX(Obj,moveAmmount#)  
    //setobjectlookat(Obj,GetVector3X(vec),GetVector3Y(vec),GetVector3Z(vec),0)
    moveobjectlocalZ(Obj,moveAmmount#)  
    x3#=getobjectx(Obj)
    z3#=getobjectz(Obj)
    hitObj=ObjectRayCast(0,getobjectx(obj),getobjecty(obj)-(maxTerrainHeight#+50),getobjectz(obj),getobjectx(obj),getobjecty(obj),getobjectz(obj))
    if hitObj>0
        y3#=GetObjectY( hitObj)+height
    else
        y3#=getObjectY(obj)
    endif     
      
    MoveObjectLocalZ(Obj,-moveAmmount#)
      
      
//////////////////////////////////////////////////////
   
    if getObjectX(Obj)<-(sizex*3) then SetObjectPosition(Obj,(sizex*3),getObjectY(Obj),getObjectZ(Obj))
    if getObjectX(Obj)>(sizex*3) then SetObjectPosition(Obj,-(sizex*3),getObjectY(Obj),getObjectZ(Obj))
    if getObjectZ(Obj)<-(sizez*3) then SetObjectPosition(Obj,getObjectX(Obj),getObjectY(Obj),(sizez*3))
    if getObjectZ(Obj)>(sizez*3) then SetObjectPosition(Obj,getObjectX(Obj),getObjectY(Obj),-(sizez*3))
    if getobjectx(obj)<-sizex then SetObjectVisible(obj,0)
    if getobjectx(obj)>sizex then SetObjectVisible(obj,0)
    if getobjectz(obj)<-sizez then SetObjectVisible(obj,0)
    if getobjectz(obj)>sizez then SetObjectVisible(obj,0)
     
endfunction
