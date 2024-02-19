function Resolve-DnsNameAdvanced {

	<#
	.SYNOPSIS
	Resolves DNS names using custom parameters.

	.DESCRIPTION
	This function enhances the built-in Resolve-DnsName cmdlet with additional features such as bulk lookup, rate limiting, and the ability to specify different DNS servers for each query.

	.PARAMETER Hostname
	Specifies one or multiple hostnames to resolve. This parameter supports array inputs.

	.PARAMETER DNSServer
	Specifies the DNS server or servers to use for resolving DNS names. Defaults to Google's DNS server (8.8.8.8).

	.PARAMETER QueryType
	Specifies the type of DNS record to query. Supported types include A, AAAA, MX, TXT, NS, SOA, PTR, CNAME, SRV, and ANY.

	.PARAMETER RateLimitMilliseconds
	Specifies the delay in milliseconds between each DNS query to avoid rate limiting or detection. Defaults to 1000 milliseconds (1 second).

	.EXAMPLE
	Resolve-DnsNameAdvanced -Hostname "example.com"

	This example resolves the A record for example.com using the default DNS server (8.8.8.8).

	.EXAMPLE
	"example.com", "anotherdomain.com" | Resolve-DnsNameAdvanced -RateLimitMilliseconds 500

	This example demonstrates bulk lookup for multiple domains with a 500 milliseconds delay between each query.

	.EXAMPLE
	Resolve-DnsNameAdvanced -Hostname "example.com" -DNSServer "8.8.8.8", "1.1.1.1"

	This example shows how to resolve a DNS name using multiple DNS servers.

	.LINK
	Resolve-DnsName

#>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string[]]$Hostname,

        [Parameter(Mandatory=$false)]
        [string[]]$DNSServer = @("8.8.8.8"), # Default to Google's DNS

        [Parameter(Mandatory=$false)]
        [ValidateSet("A", "AAAA", "MX", "TXT", "NS", "SOA", "PTR", "CNAME", "SRV", "ANY")]
        [string]$QueryType = "A",

        [Parameter(Mandatory=$false)]
        [int]$RateLimit = 1000 # Default rate limit delay
    )

    Begin {
        # Initialize a counter to keep track of the current DNS server index
        $serverIndex = 0
    }

    Process {
        foreach ($h in $Hostname) {
            # Use modulo operator to cycle through DNS servers array if multiple are provided
            $currentDNSServer = $DNSServer[$serverIndex % $DNSServer.Length]
            $serverIndex++

            try {
                # Use the Resolve-DnsName cmdlet with the provided parameters, without TimeoutSeconds
                $results = Resolve-DnsName -Name $h -Type $QueryType -Server $currentDNSServer -ErrorAction Stop
                # Output the results
                $results
            }
            catch {
                Write-Error "Failed to resolve DNS name for $h using server $currentDNSServer : $_"
            }

            # Implement rate limiting if specified
            if ($RateLimit -gt 0) {
                Start-Sleep -Milliseconds $RateLimit
            }
        }
    }
}
