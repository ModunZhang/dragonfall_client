/*
* cocos2d-x   http://www.cocos2d-x.org
*
* Copyright (c) 2010-2011 - cocos2d-x community
* 
* Portions Copyright (c) Microsoft Open Technologies, Inc.
* All Rights Reserved
* 
* Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. 
* You may obtain a copy of the License at 
* 
* http://www.apache.org/licenses/LICENSE-2.0 
* 
* Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an 
* "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
* See the License for the specific language governing permissions and limitations under the License.
*/

#include "MediaStreamer.h"

#include <Mfidl.h>
#include <Mfreadwrite.h>
#include <Mfapi.h>

#include <wrl\wrappers\corewrappers.h>
#include <ppltasks.h>
#include"lame.h"
using namespace Microsoft::WRL;
using namespace Windows::Storage;
using namespace Windows::Storage::FileProperties;
using namespace Windows::Storage::Streams;
using namespace Windows::Foundation;
using namespace Windows::ApplicationModel;
using namespace Concurrency;

#ifndef MAKEFOURCC
    #define MAKEFOURCC(ch0, ch1, ch2, ch3)                              \
                ((uint32)(byte)(ch0) | ((uint32)(byte)(ch1) << 8) |       \
                ((uint32)(byte)(ch2) << 16) | ((uint32)(byte)(ch3) << 24 ))
#endif /* defined(MAKEFOURCC) */

inline void ThrowIfFailed(HRESULT hr)
{
    if (FAILED(hr))
    {
        // Set a breakpoint on this line to catch DX API errors.
        throw Platform::Exception::CreateException(hr);
    }
}

MediaStreamer::MediaStreamer() :
    m_offset(0)
{
    ZeroMemory(&m_waveFormat, sizeof(m_waveFormat));
    m_location = Package::Current->InstalledLocation;
    m_locationPath = Platform::String::Concat(m_location->Path, "\\Assets\\Resources\\");
}

MediaStreamer::~MediaStreamer()
{
}
Platform::Array<byte>^ MediaStreamer::ReadData(
    _In_ Platform::String^ filename
    )
{
    CREATEFILE2_EXTENDED_PARAMETERS extendedParams = {0};
    extendedParams.dwSize = sizeof(CREATEFILE2_EXTENDED_PARAMETERS);
    extendedParams.dwFileAttributes = FILE_ATTRIBUTE_NORMAL;
    extendedParams.dwFileFlags = FILE_FLAG_SEQUENTIAL_SCAN;
    extendedParams.dwSecurityQosFlags = SECURITY_ANONYMOUS;
    extendedParams.lpSecurityAttributes = nullptr;
    extendedParams.hTemplateFile = nullptr;

    Wrappers::FileHandle file(
        CreateFile2(
            filename->Data(),
            GENERIC_READ,
            FILE_SHARE_READ,
            OPEN_EXISTING,
            &extendedParams
            )
        );
    if (file.Get()==INVALID_HANDLE_VALUE)
    {
        throw ref new Platform::FailureException();
    }

    FILE_STANDARD_INFO fileInfo = {0};
    if (!GetFileInformationByHandleEx(
        file.Get(),
        FileStandardInfo,
        &fileInfo,
        sizeof(fileInfo)
        ))
    {
        throw ref new Platform::FailureException();
    }

    if (fileInfo.EndOfFile.HighPart != 0)
    {
        throw ref new Platform::OutOfMemoryException();
    }

    Platform::Array<byte>^ fileData = ref new Platform::Array<byte>(fileInfo.EndOfFile.LowPart);

    if (!ReadFile(
        file.Get(),
        fileData->Data,
        fileData->Length,
        nullptr,
        nullptr
        ) )
    {
        throw ref new Platform::FailureException();
    }

    return fileData;
}


//dannyhe
void MediaStreamer::InitializeMp3(__in const WCHAR* url)
{

	WCHAR filePath[MAX_PATH] = { 0 };
	if ((wcslen(url) > 1 && url[1] == ':'))
	{
		// path start with "x:", is absolute path
		wcscat_s(filePath, url);
	}
	else if (wcslen(url) > 0
		&& (L'/' == url[0] || L'\\' == url[0]))
	{
		// path start with '/' or '\', is absolute path without driver name
		wcscat_s(filePath, m_locationPath->Data());
		// remove '/' or '\\'
		wcscat_s(filePath, (const WCHAR*)url[1]);
	}
	else
	{
		wcscat_s(filePath, m_locationPath->Data());
		wcscat_s(filePath, url);
	}

	unsigned int        decodedLength = 0;
	std::vector<std::unique_ptr<unsigned char[]>> wavBuffer;
	std::vector<int>    mp3BufferSize;
	mp3data_struct      mp3Header = {};

	struct hip_closer
	{
		void operator()(hip_t hip) { ::hip_decode_exit(hip); }
	};
	std::unique_ptr<std::remove_pointer<hip_t>::type, hip_closer> hip(::hip_decode_init());

	FILE * pMp3File = nullptr;
	struct file_closer
	{
		void operator()(FILE* file) { ::fclose(file); }
	};
	ThrowIfFailed(::_wfopen_s(&pMp3File, filePath, L"rb") == 0);
	std::unique_ptr<FILE, file_closer> mp3File(pMp3File);
	pMp3File = nullptr;

	const int frameBufferSize = 128;
	static unsigned char frameBuffer[frameBufferSize];

	// If there is ID3 tags start skipping ID3 tags to locate where the MP3 data starts.
	size_t readLength = 4;
	ThrowIfFailed(::fread_s(frameBuffer, frameBufferSize, 1, readLength, mp3File.get()) == readLength);
	if (frameBuffer[0] == 'I' && frameBuffer[1] == 'D' && frameBuffer[2] == '3')
	{
		readLength = 6;
		ThrowIfFailed(::fread_s(&frameBuffer[4], frameBufferSize - 4, 1, readLength, mp3File.get()) == readLength);
		GetLengthOfId3v2Tag(&frameBuffer[6], (int *)&readLength);
		ThrowIfFailed(::fseek(mp3File.get(), readLength, SEEK_CUR) == 0);
	}
	else
	{
		// Reset where we start parsing the MP3 data to the file beginning.
		ThrowIfFailed(::fseek(mp3File.get(), 0, SEEK_SET) == 0);
	}

	int skipSamples = 528 + 1;          // There are 529 samples we need to skip. Why 529? Just a MAGIC number from the lame library!
	while (::fread_s(frameBuffer, frameBufferSize, 1, frameBufferSize, mp3File.get()) > 0)
	{
		const int INBUF_SIZE = 1152;
		static short pcmL[INBUF_SIZE];
		static short pcmR[INBUF_SIZE];
		int samples = 0;

		// Start looking for MP3 headers
		if (!mp3Header.header_parsed)
		{
			samples = ::hip_decode_headers(hip.get(), frameBuffer, frameBufferSize, pcmL, pcmR, &mp3Header);
			continue;
		}

		samples = ::hip_decode(hip.get(), frameBuffer, frameBufferSize, pcmL, pcmR);
		if (samples == -1)
		{
			break;
		}
		else if (samples == 0)
		{
			continue;
		}

		if (skipSamples > 0
			&& skipSamples > samples)
		{
			skipSamples -= samples;
			continue;
		}

		if (samples > skipSamples)
		{
			static char decodingBuffer[2 * INBUF_SIZE * 2];
			int decodingLength = 0;
			int startIndex = skipSamples;
			skipSamples = 0;

			typedef void(*LeftRightChannelsToBuffer) (const short pcmL, const short pcmR, char * buffer, int & pos);
			LeftRightChannelsToBuffer bufferDataMerger = nullptr;
			if (mp3Header.stereo == 1)
			{
				bufferDataMerger = [](const short pcmL, const short pcmR, char * buffer, int & pos)
				{
					UNREFERENCED_PARAMETER(pcmR);
					buffer[pos++] = LO_BYTE(pcmL);
					buffer[pos++] = HI_BYTE(pcmL);
				};
			}
			else
			{
				bufferDataMerger = [](const short pcmL, const short pcmR, char * buffer, int & pos)
				{
					buffer[pos++] = LO_BYTE(pcmL);
					buffer[pos++] = HI_BYTE(pcmL);
					buffer[pos++] = LO_BYTE(pcmR);
					buffer[pos++] = HI_BYTE(pcmR);
				};
			}

			for (int i = startIndex; i < samples; ++i)
			{
				bufferDataMerger(pcmL[i], pcmR[i], decodingBuffer, decodingLength);
			}

			std::unique_ptr<unsigned char[]> decodedBuffer(new (std::nothrow) unsigned char[decodingLength]);
			ThrowIfFailed(decodedBuffer!=NULL);
			ThrowIfFailed(::memcpy_s(decodedBuffer.get(), decodingLength, decodingBuffer, decodingLength) == 0);
			wavBuffer.emplace_back(decodedBuffer.release());
			mp3BufferSize.push_back(decodingLength);
			decodedLength += decodingLength;
		}
	}
	ThrowIfFailed(decodedLength > 0);

	m_data.resize(decodedLength);
	int dataIndex = 0;
	for (unsigned int i = 0; i < wavBuffer.size(); ++i)
	{
		ThrowIfFailed(::memcpy_s((void*)&m_data[dataIndex], mp3BufferSize[i], wavBuffer[i].get(), mp3BufferSize[i]) == 0);
		dataIndex += mp3BufferSize[i];
	}

	m_waveFormat.wFormatTag = WAVE_FORMAT_PCM;
	m_waveFormat.nChannels = (WORD)mp3Header.stereo;
	m_waveFormat.nSamplesPerSec = mp3Header.samplerate;
	m_waveFormat.wBitsPerSample = (mp3Header.samplerate == 96, 000) ? 24 : 16;           // Sample rate 44,100 or 48,000 is 16 bits/sample but 96,000 is 24 bits/sample.
	m_waveFormat.nBlockAlign = m_waveFormat.nChannels * m_waveFormat.wBitsPerSample / 8;
	m_waveFormat.nAvgBytesPerSec = m_waveFormat.nSamplesPerSec * m_waveFormat.nBlockAlign;
	m_waveFormat.cbSize = 0;
}

void MediaStreamer::GetLengthOfId3v2Tag(_In_ const unsigned char * buf, _Outptr_ int * pLength)
{
	unsigned int b0 = buf[0] & 0x7f;
	unsigned int b1 = buf[1] & 0x7f;
	unsigned int b2 = buf[2] & 0x7f;
	unsigned int b3 = buf[3] & 0x7f;
	*pLength = (((((b0 << 7) + b1) << 7) + b2) << 7) + b3;
}
void MediaStreamer::Initialize(__in const WCHAR* url)
{

    WCHAR filePath[MAX_PATH] = {0};
	if ((wcslen(url) > 1 && url[1] == ':'))
	{
		// path start with "x:", is absolute path
		wcscat_s(filePath, url);
	}
	else if (wcslen(url) > 0 
		&& (L'/' == url[0] || L'\\' == url[0]))
	{
		// path start with '/' or '\', is absolute path without driver name
		wcscat_s(filePath, m_locationPath->Data());
		// remove '/' or '\\'
		wcscat_s(filePath, (const WCHAR*)url[1]);
	}else
	{
		wcscat_s(filePath, m_locationPath->Data());
		wcscat_s(filePath, url);
	}


	Platform::Array<byte>^ data = ReadData(ref new Platform::String(filePath));
	UINT32 length = data->Length;
	const byte * dataPtr = data->Data;
	UINT32 offset = 0;

	DWORD riffDataSize = 0;

	auto ReadChunk = [&length, &offset, &dataPtr, &riffDataSize](DWORD fourcc, DWORD& outChunkSize, DWORD& outChunkPos) -> HRESULT
	{
		while (true)
		{
			if (offset + sizeof(DWORD) * 2 >= length)
			{
				return E_FAIL;
			}

			// Read two DWORDs.
			DWORD chunkType = *reinterpret_cast<const DWORD *>(&dataPtr[offset]);
			DWORD chunkSize = *reinterpret_cast<const DWORD *>(&dataPtr[offset + sizeof(DWORD)]);
			offset += sizeof(DWORD) * 2;

			if (chunkType == MAKEFOURCC('R', 'I', 'F', 'F'))
			{
				riffDataSize = chunkSize;
				chunkSize = sizeof(DWORD);
				outChunkSize = sizeof(DWORD);
				outChunkPos = offset;
			}
			else
			{
				outChunkSize = chunkSize;
				outChunkPos = offset;
			}

			offset += chunkSize;

			if (chunkType == fourcc)
			{
				return S_OK;
			}
		}
	};

	// Locate riff chunk, check the file type.
	DWORD chunkSize = 0;
	DWORD chunkPos = 0;

	ThrowIfFailed(ReadChunk(MAKEFOURCC('R', 'I', 'F', 'F'), chunkSize, chunkPos));
	if (*reinterpret_cast<const DWORD *>(&dataPtr[chunkPos]) != MAKEFOURCC('W', 'A', 'V', 'E')) ThrowIfFailed(E_FAIL);

	// Locate 'fmt ' chunk, copy to WAVEFORMATEXTENSIBLE.
	ThrowIfFailed(ReadChunk(MAKEFOURCC('f', 'm', 't', ' '), chunkSize, chunkPos));
	ThrowIfFailed((chunkSize <= sizeof(m_waveFormat)) ? S_OK : E_FAIL);
	CopyMemory(&m_waveFormat, &dataPtr[chunkPos], chunkSize);

	// Locate the 'data' chunk and copy its contents to a buffer.
	ThrowIfFailed(ReadChunk(MAKEFOURCC('d', 'a', 't', 'a'), chunkSize, chunkPos));
	m_data.resize(chunkSize);
	CopyMemory(m_data.data(), &dataPtr[chunkPos], chunkSize);

	m_offset = 0;
}

void MediaStreamer::ReadAll(uint8* buffer, uint32 maxBufferSize, uint32* bufferLength)
{
	UINT32 toCopy = m_data.size() - m_offset;
	if (toCopy > maxBufferSize) toCopy = maxBufferSize;

	CopyMemory(buffer, m_data.data(), toCopy);
	*bufferLength = toCopy;

	m_offset += toCopy;
	if (m_offset > m_data.size()) m_offset = m_data.size();
}

void MediaStreamer::Restart()
{
	m_offset = 0;
}
