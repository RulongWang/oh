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
 * HproseResultMode.as                                    *
 *                                                        *
 * HproseResultMode enum for ActionScript 2.0.            *
 *                                                        *
 * LastModified: Jun 22, 2011                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
class hprose.client.HproseResultMode {
    public static var Normal:Number = 0;
    public static var Serialized:Number = 1;
    public static var Raw:Number = 2;
    public static var RawWithEndTag:Number = 3;
}