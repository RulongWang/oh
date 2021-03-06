﻿/**********************************************************\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: http://www.hprose.com/                 |
|                   http://www.hprose.net/                 |
|                   http://www.hprose.org/                 |
|                                                          |
\**********************************************************/
/**********************************************************\
 *                                                        *
 * HproseHttpInvoker.as                                   *
 *                                                        *
 * hprose http invoker class for ActionScript 3.0.        *
 *                                                        *
 * LastModified: Jul 6, 2011                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
package hprose.client {
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.ProgressEvent;
    import flash.display.Sprite;
    import flash.net.URLStream;
    import flash.utils.ByteArray;
    import flash.utils.IDataInput;
    
    import hprose.io.HproseException;
    import hprose.io.HproseReader;
    import hprose.io.HproseTags;
    import hprose.io.HproseWriter;
    
    [Event(name="error", type="hprose.client.HproseErrorEvent")]
    [Event(name="success", type="hprose.client.HproseSuccessEvent")]
    [Event(name="progress", type="flash.events.ProgressEvent")]
    public class HproseHttpInvoker extends Sprite {
        private var url:String;
        private var header:Object;
        private var func:String;
        private var args:Array;
        private var byref:Boolean = false;
        private var dispatcher:EventDispatcher;
        private var progressId:Number;
        private var result:*;
        private var success:Boolean;
        private var completed:Boolean;
        private var timeout:uint;
        private var resultMode:int;
        private var httpRequest:HproseHttpRequest = null;
        
        public function HproseHttpInvoker(url:String, header:Object, func:String, args:Array, byref:Boolean, callback:Function, errorHandler:Function, progressHandler:Function, dispatcher:EventDispatcher, timeout:uint, resultMode:int) {
            this.url = url;
            this.header = header;
            this.func = func;
            this.args = args;
            this.byref = byref;
            this.dispatcher = dispatcher;
            this.timeout = timeout;
            this.resultMode = resultMode;
            if (callback != null) {
                start(callback, errorHandler, progressHandler);
            }
        }

        public function get byRef():Boolean {
            return byref;
        }
        
        public function set byRef(value:Boolean):void {
            byref = value;
        }
        
        public function isSuccess():Boolean {
            return success;
        }
        
        public function isCompleted():Boolean {
            return completed;
        }
        
        public function getResult():* {
            return result;
        }
        
        public function getArguments():Array {
            return args;
        }
        
        public function start(callback:Function = null, errorHandler:Function = null, progressHandler:Function = null):HproseHttpInvoker {
            var stream:ByteArray = new ByteArray();
            stream.writeByte(HproseTags.TagCall);
            var writer:HproseWriter = new HproseWriter(stream);
            writer.writeString(func, false);
            if (args.length > 0) {
                writer.reset();
                writer.writeList(args, false);
            }
            if (byref) {
                writer.writeBoolean(true);
            }
            stream.writeByte(HproseTags.TagEnd);
            stream.position = 0;
            completed = false;
            var invoker:HproseHttpInvoker = this;
            httpRequest = HproseHttpRequest.post(url, header, stream,
            function(stream:IDataInput):void {
                if (invoker.resultMode == HproseResultMode.RawWithEndTag ||
                    invoker.resultMode == HproseResultMode.Raw) {
                    var data:ByteArray = new ByteArray();
                    stream.readBytes(data);
                    data.position = 0;
                    if (invoker.resultMode == HproseResultMode.Raw) {
                        data.length = data.length - 1;
                    }
                    invoker.result = data;
                }
                else {
                    var reader:HproseReader = new HproseReader(stream);
                    var tag:int;
                    var error:Error = null;
                    try {
                        while ((tag = reader.checkTags(
                            [HproseTags.TagResult,
                             HproseTags.TagArgument,
                             HproseTags.TagError,
                             HproseTags.TagEnd])) !== HproseTags.TagEnd) {
                            switch (tag) {
                                case HproseTags.TagResult:
                                    if (invoker.resultMode == HproseResultMode.Serialized) {
                                        invoker.result = reader.readRaw();
                                        invoker.result.position = 0;
                                    }
                                    else {
                                        invoker.result = reader.unserialize();
                                    }
                                    break;
                                case HproseTags.TagArgument:
                                    reader.reset();
                                    invoker.args = reader.readList();
                                    break;
                                case HproseTags.TagError:
                                    reader.reset();
                                    error = new HproseException(reader.readString());
                                    break;
                            }
                        }
                    }
                    catch (e:Error) {
                        error = e;
                    }
                }
                invoker.completed = true;
                invoker.success = (error == null);
                if (invoker.success) {
                    if (callback != null) {
                        callback(invoker.result, invoker.args);
                    }
                    else if (invoker.hasEventListener(HproseSuccessEvent.SUCCESS)) {
                        invoker.dispatchEvent(new HproseSuccessEvent(invoker.result, invoker.args));
                    }
                }
                else {
                    if (errorHandler != null) {
                        errorHandler(invoker.func, error);
                    }
                    else if (invoker.hasEventListener(HproseErrorEvent.ERROR)) {
                        invoker.dispatchEvent(new HproseErrorEvent(invoker.func, error));
                    }
                    else {
                        invoker.dispatcher.dispatchEvent(new HproseErrorEvent(invoker.func, error));
                    }
                }
            },
            function progress(event:ProgressEvent):void {
                if (progressHandler != null) {
                    progressHandler(event.bytesLoaded, event.bytesTotal);
                }
                else if (invoker.hasEventListener(ProgressEvent.PROGRESS)) {
                    invoker.dispatchEvent(event);
                }
            }, timeout);
            return this;
        }

        public function stop():void {
            if (httpRequest) {
                httpRequest.stop();
            }
        }
    }
}