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

package zpartan.ux
{
    
    import flash.display.Sprite;
    
    public class InitSprite
    {
        
        
        private var mc:             Sprite;
        private var fields:         Array;
        private var x:              Float;
        private var y:              Float;
        private var width:          Float;
        private var height:         Float;
        private var scaleX:         Float;
        private var scaleY:         Float;
        private var visible:        Bool;
        private var alpha:          Float;
        private var rotation:       Float;
        
        
        public function InitSprite( mc_: Sprite, fields_: Array<String> )
        {
            
            mc      = mc_;
            fields  = fields_;
            
            for( all in fields_ ) Reflect.field( this, all, Reflect.getProperty( mc_, all ) );
            
        }
        
        
        public function reset()
        {
            
            for( all in fields ) if( all != 'x' || all != 'y' ) Reflect.setProperty( mc_, all, Reflect.getField( mc_, all ) );
            
            // set x and y last
            if( x != null ) mc.x = x;
            if( y != null ) mc.y = y;
            
        }
        
        
    }
    
    
}