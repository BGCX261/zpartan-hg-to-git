/*
* Copyright (c) 2012, Justinfront Ltd
*   author:  Justin L Mills
*   email:   JLM at Justinfront dot net
*   created: 17 June 2012
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of the Justinfront Ltd nor the
*       names of its contributors may be used to endorse or promote products
*       derived from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY Justinfront Ltd ''AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL Justinfront Ltd BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package zpartan.media;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;

import flash.media.Camera;
import flash.media.Video;
import flash.media.Microphone;

import flash.net.NetStream;
import flash.net.NetConnection;

import flash.events.NetStatusEvent;


class WebCameraView
{
    
    
    private var cam:               Camera;
    private var mic:               Microphone;
    private var vid:               Video;
    private var scope:             Sprite;
    private var width:             Float;
    private var height:            Float;
    private var nc:                NetConnection;
    private var ns:                NetStream;
    
    public function getHeight():    Float { return height; }
    public function getWidth():     Float { return width;  }
    
    
    
    public function new( scope_: Sprite )
    {
        
        scope  = scope_;
        cam    = Camera.getCamera();
        mic    = Microphone.getMicrophone();
        
    }
    
    
    public function send( nc_: NetConnection )
    {
        
        nc = nc_;
        
        if ( cam != null )
        {
            
            cam.setMode( 215, 215, 30 );
            
            vid                 = new Video( cam.width, cam.height );
            
            vid.attachCamera( cam );
            scope.addChild( vid );
            
            var scale           = 215/cam.width;
            vid.width           = cam.width*scale;
            vid.height          = cam.height*scale;
            width               = vid.width;
            height              = vid.height;
            ns                  = new NetStream( nc, NetStream.DIRECT_CONNECTIONS );
            
            ns.addEventListener( NetStatusEvent.NET_STATUS, traceStatus ); 
            ns.publish( "media" ); 
            ns.attachAudio( mic ); 
            ns.attachCamera( cam );
            
        } 
        else 
        {
            
            trace("You need a camera.");
            
        }
        
    }
    
    
    private function traceStatus( e: NetStatusEvent )
    {
        
       trace( ' stream status event  ' );
        if ( e.info.level == "error" ) 
        {
            
            trace ("Fail");
            return;
        }
        
        switch( e.info.code ) 
        {
            
            case "NetStream.Play.Start":
                trace( "Stream Success" );
                
            case "NetStream.Buffer.Empty":
                trace( "buffer empty" );
            
        }
        
    }
    
    
    // maybe useful?
    public function photo(): BitmapData
    {
        
        var b = new BitmapData( Std.int( scope.width ), Std.int( scope.height ) );
        b.draw( scope );
        return b;
        
    }
    
}