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
    
import flash.display.MovieClip;
import flash.display.Sprite; 
import flash.events.AsyncErrorEvent;
import flash.events.NetStatusEvent;
import flash.events.SecurityErrorEvent;
import flash.media.SoundMixer;
import flash.media.SoundTransform;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.net.NetStreamInfo;
import zpartanlite.DispatchTo;


class ProgressiveVideo 
{
    
    
    private var ns:                         NetStream;
    private var nc:                         NetConnection;
    private var videoHolder:                Sprite;
    private var vid:                        Video;
    private var src:                        String;
    private var started:                    Bool;
    private var autoRepeat:                 Bool;
    private var infoObject:                 Dynamic;
    private var soundTransform:             SoundTransform;
    private var maxWidth:                   Int;
    private var maxHeight:                  Int;
    public var sub:                         String;
    public var largeX:                      Int;
    public var largeY:                      Int;
    public var wide:                        Int;
    public var hi:                          Int;
    
    
    public var endSignal:                   DispatchTo;
    public var streamReadySignal:           DispatchTo;
    public var subtitleSignal:              DispatchTo;
    
    
    
    public function new() 
    {
        
        endSignal                   = new DispatchTo();
        streamReadySignal           = new DispatchTo();
        subtitleSignal              = new DispatchTo();
        autoRepeat                  = false;
        started                     = false;
        nc                          = new NetConnection();
        vid                         = new Video();
        videoHolder                 = new Sprite();
        videoHolder.addChild( vid );
           
        vid.smoothing                = true;
        vid.height                   = 1;
        vid.width                    = 1;
        infoObject                   = null;
        nc.addEventListener( NetStatusEvent.NET_STATUS,            netStatusHandler );
        nc.addEventListener( SecurityErrorEvent.SECURITY_ERROR,    securityErrorHandler );
        nc.connect( null );
        maxWidth                     = 0;
        maxHeight                    = 0;
        ns.bufferTime                = 3;
        
    }
    
    
    public function volume( vol: Float )
    {
        
        ns.soundTransform = new SoundTransform( vol );
        
    }
    
    
    public function endVideo()
    {
        
        ns.pause();
        ns.seek( 0 );
        vid.visible = false;
        
    }
    
    
    public function setVideo( src_: String )
    {
        
        src = src_;
    
    }
    
    
    public function killSound()
    {
        
        SoundMixer.stopAll();
        
    }
    
    
    public function getHolder(): Sprite
    {
        
        return videoHolder;
        
    }
    
    
    public function setAutoRepeat( val: Bool )
    {
        
        autoRepeat = val;
        
    }
    
    
    private function restartVid( )
    {
        vid.visible = false;
        if( ns != null )
        {
            
            ns.pause();  
            ns.seek( 0 );
            
        }
        
    }
    
    
    private function netStatusHandler( event: NetStatusEvent )
    {
        
        switch ( event.info.code ) 
        {
            
            case "NetConnection.Connect.Success":
                if( ns != null )
                {
                    ns.close();
                    ns = null;
                }
                #if videoFeedback 
                    trace( 'video stream connected ');
                #end
                connectStream();
                //vid_sound = new Sound( _soundns.publish(), context );
                
            case "NetStream.Play.Stop":
                #if videoFeedback 
                    trace( src + " video complete" );
                #end
                started = false;
                endSignal.dispatch();
                if ( autoRepeat )
                {
                    playVideo();
                }
                
            case "NetStream.Play.StreamNotFound":
                #if videoFeedback 
                    trace( "unfound video: " + src );
                #end
        }
        
    }
    
    
    private function connectStream()
    {
        
        ns                     = new NetStream( nc );
        ns.bufferTime          = 3;
        
        ns.addEventListener( NetStatusEvent.NET_STATUS,            netStatusHandler      );
        ns.addEventListener( AsyncErrorEvent.ASYNC_ERROR,          asyncErrorHandler      );
        nc.addEventListener( SecurityErrorEvent.SECURITY_ERROR,    securityErrorHandler );
        
        ns.client              = this;
        
        vid.attachNetStream( ns );
        
        streamReadySignal.dispatch();
        
    }
    
    
    public function playVideo()
    {
        
        ns.close() ;// not sure if this line good
        if( ns != null && src != null )
        {
            started = true;
            soundTransform = new SoundTransform();
            ns.play( src );
                    
            vid.visible = true ;
        }
        
    }
    
    
    public function resumeVideo()
    {
        
        ns.resume();
        if( vid.visible == false )
        {
            openVid();
        }
        
    }
    
    
    public function pauseVideo()
    {
        
        ns.pause();
        
    }
    
    
    public function onCuePoint( infoObject_: Dynamic ) { onSubtitle( infoObject_.name ); }
    public function onTextData( infoObject_: Dynamic ) { onSubtitle( infoObject_.text ); }
    public function onSubtitle( sub_: String )
    { 
        
        sub = sub_;  
        subtitleSignal.dispatch();
        #if videoFeedback 
            trace( sub );
        #end
    }
    
    
    public function onMetaData( infoObject_: Dynamic )
    {
        
        if( vid.visible )
        {
            
            infoObject = infoObject_;
            openVid();
            
        }
        
    }
    
    
    public function setMaxWidth( val: Int ): Int
    {
        
        maxWidth = val;
        return maxWidth;
        
    }
    
    
    public function setMaxHeight( val: Int ): Int
    {
        
        maxHeight = val;
        return maxHeight;
        
    }
    
    
    // This may need adjustments
    private function openVid()
    {
        
        vid.visible = true;
        
        if ( infoObject != null && vid != null  )
        {
            
            vid.width  = infoObject.width;
            vid.height = infoObject.height;    
            
        }
        
        /*
        // resize if too large
        if ( maxHeight != 0 && maxWidth != 0 )
        {
        
            if ( videoHolder.height > maxHeight || videoHolder.width > maxWidth )
            {
                
                var scale = ( maxHeight/videoHolder.height < maxWidth/videoHolder.width )?maxWidth/videoHolder.width: maxHeight/videoHolder.height;
                
                videoHolder.scaleX = scale;
                videoHolder.scaleY = scale;
                
             }
            
         }
         */
    }
    
    
    
    private function securityErrorHandler( event: SecurityErrorEvent )
    {
        
        trace("securityErrorHandler: " + event);
        
    }
    
    
    private function asyncErrorHandler( event: AsyncErrorEvent )
    {
        
        // ignore AsyncErrorEvent events.
        
    }
    
    
}
