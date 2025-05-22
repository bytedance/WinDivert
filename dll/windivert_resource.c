/*
 * windivert_resource.c
 * (C) 2025, all rights reserved,
 *
 * This file is part of WinDivert.
 *
 * WinDivert is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or (at your
 * option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
 * License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * WinDivert is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2 of the License, or (at your option)
 * any later version.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * for more details.
 * 
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc., 51
 * Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 */

#include <wchar.h>
#include <Windows.h>
#include <Shlwapi.h>
#include <winerror.h>

/**
 * Locates RT_RCDATA resource memory address and size.
 *
 * @return Resource address on success. If the function fails, the return value is NULL. To get extended error
 *         information, call GetLastError.
 */
static const VOID* WinDivertResourceGetAddress(
	_In_ HINSTANCE resource_module, 
	_In_ LPCWSTR resource_name, 
	_Out_ DWORD* size)
{
	HRSRC found_resource = FindResourceW(resource_module, resource_name, RT_RCDATA);
	if (!found_resource)
	{
		return NULL;
	}
	*size = SizeofResource(resource_module, found_resource);
	if (!*size)
	{
		return NULL;
	}
	HGLOBAL LoadedResource = LoadResource(resource_module, found_resource);
	if (!LoadedResource)
	{
		return NULL;
	}
	BYTE* address = LockResource(LoadedResource);
	if (!address)
	{
		SetLastError(ERROR_LOCK_FAILED);
		return NULL;
	}
	return address;
}

/**
 * Copies resource to a file.
 *
 * @return If the function succeeds, the return value is nonzero. If the function fails, the return value is zero. To
 *         get extended error information, call GetLastError.
 */
static BOOL WinDivertResourceCopyToFile(
	_Out_ LPCWSTR destination_path,
	_In_ LPCWSTR resource_name,
	_In_ HINSTANCE resource_module)
{
	DWORD resource_size;
	const VOID* locked_resource = WinDivertResourceGetAddress(resource_module, resource_name, &resource_size);
	if (!locked_resource)
	{
		return FALSE;
	}

	HANDLE destination_handle = CreateFileW(
		destination_path,
		GENERIC_WRITE,
		0,
		NULL, // &SecurityAttributes,
		CREATE_ALWAYS,
		FILE_ATTRIBUTE_NORMAL | FILE_ATTRIBUTE_TEMPORARY,
		NULL);
	if (destination_handle == INVALID_HANDLE_VALUE)
	{
		return FALSE;
	}

	DWORD written_bytes;
	DWORD last_error = ERROR_SUCCESS;
	if (!WriteFile(destination_handle, locked_resource, resource_size, &written_bytes, NULL))
	{
		last_error = GetLastError();
		goto WinDivertResourceCopyToFileCleanupDestinationHandle;
	}
	if (written_bytes != resource_size)
	{
		last_error = ERROR_WRITE_FAULT;
		goto WinDivertResourceCopyToFileCleanupDestinationHandle;
	}
WinDivertResourceCopyToFileCleanupDestinationHandle:
	CloseHandle(destination_handle);
	SetLastError(last_error);
	return ERROR_SUCCESS == last_error;
}
