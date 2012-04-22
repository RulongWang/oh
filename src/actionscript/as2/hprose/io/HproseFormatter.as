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
 * HproseFormatter.as                                     *
 *                                                        *
 * hprose formatter class for ActionScript 2.0.           *
 *                                                        *
 * LastModified: Jul 7, 2011                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
import hprose.io.HproseReader;
import hprose.io.HproseWriter;
import hprose.io.HproseStringInputStream;
import hprose.io.HproseStringOutputStream;

class hprose.io.HproseFormatter {
    public static function serialize(o, stream:HproseStringOutputStream):HproseStringOutputStream {
        if (stream == null) {
            stream = new HproseStringOutputStream();
        }
        var writer:HproseWriter = new HproseWriter(stream);
        writer.serialize(o);
        return stream;
    }
    public static function unserialize(stream) {
        if (typeof(stream) == "string") {
            stream = new HproseStringInputStream(stream);
        }
        var reader:HproseReader = new HproseReader(stream);
        return reader.unserialize();
    }
}