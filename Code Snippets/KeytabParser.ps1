param(
    [Parameter(Mandatory)]
    [string]$Path
)

#Created by Pierre.Audonnet@microsoft.com
#
#Got keytab structure from http://www.ioplex.com/utilities/keytab.txt
#
#  keytab {
#      uint16_t file_format_version;                    /* 0x502 */
#      keytab_entry entries[*];
# };
#
#  keytab_entry {
#      int32_t size;
#      uint16_t num_components;    /* sub 1 if version 0x501 */
#      counted_octet_string realm;
#      counted_octet_string components[num_components];
#      uint32_t name_type;   /* not present if version 0x501 */
#      uint32_t timestamp;
#      uint8_t vno8;
#      keyblock key;
#      uint32_t vno; /* only present if >= 4 bytes left in entry */
#  };
#
#  counted_octet_string {
#      uint16_t length;
#     uint8_t data[length];
#  };
#
#  keyblock {
#      uint16_t type;
#      counted_octet_string;
#  };

#$keytabefile = "C:\Users\piaudonn\Documents\Kerberos\816.keytab"

#Convert the file to an array of bytes
[byte[]]$keytab = Get-Content -Path $Path -Encoding Byte
#We are going to read the "stream" byte per byte... Old school mama
$script:offset = 0 #We use this to keep track where we are in the file
$script:keytabStream = [byte[]]$keytab
#Need to know how many bytes in total to manage situation with padding
$keytabStreamLenght = $script:keytabStream.Count
#Keytabs can have multiple entries (although ktpass can't do that, other utility might)
$nbEntry = 0
#Got the list from the Netmon parser
$encType = @{
    1 = 'des-cbc-crc'
    2 = 'des-cbc-md4'
    3 = 'des-cbc-md5'
    4 = '[reserved]'
    5 = 'des3-cbc-md5'
    6 = '[reserved]'
    7 = 'des3-cbc-sha1'
    9 = 'dsaWithSHA1-CmsOID'
    10 = 'md5WithRSAEncryption-CmsOID'
    11 = 'sha1WithRSAEncryption-CmsOID'
    12 = 'rc2CBC-EnvOID'
    13 = 'rsaEncryption-EnvOID'
    14 = 'rsaES-OAEP-ENV-OID'
    15 = 'des-ede3-cbc-Env-OID'
    16 = 'des3-cbc-sha1-kd'
    17 = 'aes128-cts-hmac-sha1-96'
    18 = 'aes256-cts-hmac-sha1-96'
    23 = 'rc4-hmac'
    24 = 'rc4-hmac-exp'
    65 = 'subkey-keymaterial'
}
$nameTypes = @{
    0 = 'NT-UNKNOWN'
    1 = 'NT-PRINCIPAL'
    2 = 'NT-SRV-INST'
    3 = 'NT-SRV-HST'
    4 = 'NT-SRV-XHST'
    5 = 'NT-UID'
    6 = 'NT-X500-PRINCIPAL'
    7 = 'NT-SMTP-NAME'
    10 = 'NT-ENTERPRISE'
}
#The big crappy function reading bytes and updating the pointer
function ReadKeytab
{
    param(
        [string]$_type,
        [int]$_size = 0
    )
    $_string = ''
    switch ($_type) {
        'UInt8'
        {
            #Little endian...
            $_size = 1
            $_value = $script:keytabStream[$script:offset]
        }
        'UInt16'
        {
            #Little endian...
            $_size = 2
            $_value = [System.BitConverter]::ToUInt16( $script:keytabStream[($script:offset+1)..($script:offset)] , 0)
        }
        'Int32'
        {
            #Little endian...
            $_size = 4
            $_value = [System.BitConverter]::ToInt32( $script:keytabStream[($script:offset+3)..($script:offset)] , 0)
        }
        'UInt32'
        {
            #Little endian...
            $_size = 4
            $_value = [System.BitConverter]::ToUInt32( $script:keytabStream[($script:offset+3)..($script:offset)] , 0)
        }
        'Key'
        {
            #Little endian...
            $_data = ''
            $_value = 0
            $_bytes = [System.BitConverter]::ToString($script:keytabStream[($script:offset)..($script:offset+$_size-1)])
            $_string = $_bytes
        }
        'String'
        {
            #Little endian...
            $_data = ''
            $_value = 0
            $_bytes = $script:keytabStream[($script:offset)..($script:offset+$_size-1)] | ForEach-Object -Process {
                $_data += [char] $_
            }
            $_string = $_data
        }

    }
    $script:offset = $script:offset + $_size
    $_hex_size = $_size * 2
    $_return = New-Object -TypeName psobject -Property @{
        _value  = $_value
        _size   = $_size
        _hex    = ( "0x{0:X$_hex_size}" -f $_value )
        _string = $_string
    }
    return $_return
}

#File Format Version
Write-Output -InputObject "Version header: $((ReadKeytab 'UInt16')._hex)"
#Parse each entry
do
{
    #Entry
    $entryentrypoint = $script:offset
    $nbEntry++
    Write-Output -InputObject "Entry id: $nbEntry"
    $entrysize = [int] (ReadKeytab 'Int32')._value
    Write-Output -InputObject "`tEntry size: $entrysize bytes"
    #Nb Component
    $nbcomponent = (ReadKeytab 'UInt16')._value + 1
    for ($i = 0; $i -le $nbcomponent-1; $i++)
    {
        [int] $nbchar = (ReadKeytab 'UInt16')._value
        Write-Output -InputObject "`tComponent $($i): $((ReadKeytab 'String' ($nbchar))._string)"
    }
    #nametype
    Write-Output -InputObject "`tName type: $($nameTypes[ [int] (ReadKeytab 'UInt32')._value ])"
    #Timestamp
    Write-Output -InputObject "`tTimestamp: $((ReadKeytab 'UInt32')._hex)"
    #vno
    Write-Output -InputObject "`tKvno: $((ReadKeytab 'UInt8')._value)"

    #Keyblock
    Write-Output -InputObject "`tKeyblock"
    Write-Output -InputObject "`t`tEncryption type: $($encType[ [int] (ReadKeytab 'UInt16')._value ])"
    [int] $nbchar = (ReadKeytab 'UInt16')._value
    Write-Output -InputObject "`t`tKey: $((ReadKeytab 'Key' ($nbchar))._string)"
    $entryexitoffset = $script:offset
    #vno
    if ( ( $entryexitoffset - $entryentrypoint ) -le ($entrysize - 4) )
    {
        Write-Output -InputObject "`tvno: $((ReadKeytab 'UInt32')._value)"
    }
}
until ($script:offset -ge $keytabStreamLenght )
