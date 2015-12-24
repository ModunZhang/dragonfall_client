#ifndef HEADER_CURL_INET_NTOP_WINRT_H
#define HEADER_CURL_INET_NTOP_WINRT_H
/***************************************************************************
 *                                  _   _ ____  _
 *  Project                     ___| | | |  _ \| |
 *                             / __| | | | |_) | |
 *                            | (__| |_| |  _ <| |___
 *                             \___|\___/|_| \_\_____|
 *
 * Copyright (C) 1998 - 2009, Daniel Stenberg, <daniel@haxx.se>, et al.
 *
 * This software is licensed as described in the file COPYING, which
 * you should have received as part of this distribution. The terms
 * are also available at http://curl.haxx.se/docs/copyright.html.
 *
 * You may opt to use, copy, modify, merge, publish, distribute and/or sell
 * copies of the Software, and permit persons to whom the Software is
 * furnished to do so, under the terms of the COPYING file.
 *
 * This software is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY
 * KIND, either express or implied.
 *
 *
 * Portions Copyright (c) Microsoft Open Technologies, Inc.  


 ***************************************************************************/
//dannyhe only needed if _MSC_VER < 1900 https://github.com/cocos2d/cocos2d-x/commit/7d22e49642c79a46290000d561cf57a2a2032205
#if _MSC_VER < 1900
char *inet_ntop(int af, const void *addr, char *buf, size_t size);
#endif

#endif /* HEADER_CURL_INET_NTOP_H */

