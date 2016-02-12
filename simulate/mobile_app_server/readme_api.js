document.write('\
<h2>\
	API Interfaces</h2>\
<div>\
	The following are the interfaces which can be used</div>\
<h3>\
	Registration</h3>\
<div>\
	For a client to register the following URL will be used. The URL will return the registration information</div>\
<div>\
	&nbsp;</div>\
<div>\
	<div>\
		<a class="quad-tooltip-toggle" target="_blank" title="https://&lt;ServerAddress&gt;/api/cmxmobile/v1/clients/register">https://&lt;ServerAddress&gt;/api/cmxmobile/v1/clients/register</a></div>\
	<ul>\
		<li>\
			ServerAddress - The IP address the server is running on</li>\
	</ul>\
	<div>\
		The following form parameters should be set</div>\
	<ul>\
		<li>\
			pushNotificationRegistrationId - Push notification registration ID</li>\
		<li>\
			apMACAddress - AP MAC address the device is joined with</li>\
		<li>\
			clientIPAddress - Current IP address of the device</li>\
		<li>\
			clientMACAddress- Device Wifi Radio MAC Address</li>\
		<li>\
			clientType - Client type string: Android or iOS</li>\
	</ul>\
	<br />\
	<div>\
		<strong>Example:</strong></div>\
	<div>\
		<a class="quad-tooltip-toggle" href="https://localhost/api/cmxmobile/v1/clients/register" target="_blank" title="https://localhost/api/cmxmobile/v1/clients/register">https://localhost/api/cmxmobile/v1/clients/register</a></div>\
	<div>\
		&nbsp;</div>\
	<div>\
		<strong>Results:</strong></div>\
</div>\
<div>\
	<ul>\
		<li>\
			4xx code if something went wrong (like the MAC address you registered with was already taken for some reason)</li>\
		<li>\
			5xx code if something went wrong on the server</li>\
		<li>\
			202/Accepted code if the server hasn&#39;t received the matching AssociationEvent yet</li>\
		<li>\
			201/Created code if everything went right. There will also be a Set-cookie header, and the URI created will be /api/cmxmobile/v1/clients/location/{deviceId}</li>\
	</ul>\
</div>\
		<h3>\
		Location Feedback</h3>\
	<div>\
		For a client to supply location feedback the following URL will be used. The URL will post the feeback location</div>\
	<div>\
		&nbsp;</div>\
	<div>\
		<div>\
			<a class="quad-tooltip-toggle" target="_blank" title="https://&lt;ServerAddress&gt;/api/cmxmobile/v1/clients/feedback/location">https://&lt;ServerAddress&gt;/api/cmxmobile/v1/clients/feedback/location</a></div>\
		<ul>\
			<li>\
				ServerAddress - The IP address the server is running on</li>\
		</ul>\
		<div>\
			The following form parameters should be set</div>\
		<ul>\
			<li>\
				x - Client X Location</li>\
			<li>\
				y - Client Y Location</li>\
		</ul>\
		<br />\
		<div>\
			<strong>Example:</strong></div>\
		<div>\
			<a class="quad-tooltip-toggle" href="https://localhost/api/cmxmobile/v1/clients/feedback/location" target="_blank" title="https://localhost/api/cmxmobile/v1/clients/feedback/location">https://localhost/api/cmxmobile/v1/clients/feedback/location</a></div>\
		<div>\
			&nbsp;</div>\
		<div>\
			<strong>Results:</strong></div>\
	</div>\
	<div>\
		<ul>\
			<li>\
				200 If Successful</li>\
		</ul>\
	</div>\
		<h3>\
	Location</h3>\
<div>\
	To get the location for a client you will use the following URL. The URL will return the location for the client</div>\
<div>\
	&nbsp;</div>\
<div>\
	<div>\
		<a class="quad-tooltip-toggle" target="_blank" title="https://&lt;ServerAddress&gt;/api/cmxmobile/v1/clients/location/&lt;DeviceId&gt;">https://&lt;ServerAddress&gt;/api/cmxmobile/v1/clients/location/&lt;DeviceId&gt;</a></div>\
	<ul>\
		<li>\
			ServerAddress - The IP address the server is running on</li>\
		<li>\
			DeviceId- This could be any ID which can be used to identify a client and can be mapped to a MAC address in the CMX Mobile App Server</li>\
	</ul>\
	<div>\
		The simulator has the following Device IDs for testing: <em>000ab8ffe9ec, 000ab8ffe9ed, 000ab8ffe9ef</em></div>\
	<br />\
	<div>\
		<strong>Example:</strong></div>\
	<div>\
		<a class="quad-tooltip-toggle" href="https://localhost/api/cmxmobile/v1/clients/location/000ab8ffe9ed" target="_blank" title="https://localhost/api/cmxmobile/v1/clients/location/000ab8ffe9ed">https://localhost/api/cmxmobile/v1/clients/location/000ab8ffe9ed</a></div>\
	<div>\
		&nbsp;</div>\
	<div>\
		<strong>Results:</strong></div>\
</div>\
<div>\
	<pre>\
{<br>\
  &quot;deviceId&quot;: &quot;000ab8ffe9ed&quot;,<br>\
  &quot;venueId&quot;: &quot;782309123536&quot;,<br>\
  &quot;floorId&quot;: &quot;730297895206518938&quot;,<br>\
  &quot;mapCoordinate&quot;: {<br>\
    &quot;x&quot;: &quot;95.21&quot;,<br>\
    &quot;y&quot;: &quot;36.11&quot;<br>\
  }<br>\
}</pre>\
</div>\
<div>\
	<h3>\
		Venue Information For All Venues</h3>\
	<div>\
		To download all venue information you will use the following URL. The URL will return the venue information for all venues</div>\
	<div>\
		&nbsp;</div>\
	<div>\
		<div>\
			<a class="quad-tooltip-toggle" target="_blank" title="https://&lt;ServerAddress&gt;/api/cmxmobile/v1/venues/info/">https://&lt;ServerAddress&gt;/api/cmxmobile/v1/venues/info/</a></div>\
		<ul>\
			<li>\
				ServerAddress - The IP address the server is running on</li>\
		</ul>\
	</div>\
	<div>\
		<a class="quad-tooltip-toggle" href="https://localhost/api/cmxmobile/v1/venues/info/" target="_blank" title="https://localhost/api/cmxmobile/v1/venues/info/">https://localhost/api/cmxmobile/v1/venues/info/</a></div>\
	<br />\
	<div>\
		<strong>Results:</strong></div>\
	<div>\
		<pre>\
[<br>\
  {<br>\
    &quot;venueId&quot;: &quot;782309123536&quot;,<br>\
    &quot;streetAddress&quot;: &quot;3625 Cisco Way, San Jose, CA 95131&quot;,<br>\
    &quot;name&quot;: &quot;Cisco&quot;,<br>\
    &quot;locationUpdateInterval&quot; : &quot;5&quot;,<br>\
    &quot;wifiConnectionMode&quot; : &quot;auto&quot;,<br>\
    &quot;preferredNetwork&quot;: [<br>\
      {<br>\
        &quot;ssid&quot;: &quot;alpha&quot;,<br>\
        &quot;password&quot;: &quot;&quot;<br>\
      },<br>\
      {<br>\
        &quot;ssid&quot;: &quot;blizzard&quot;,<br>\
        &quot;password&quot;: &quot;&quot;<br>\
      }<br>\
    ]<br>\
  }<br>\
]</pre>\
	</div>\
	<h3>\
		Venue Information For A Venue</h3>\
	<div>\
		To download a venue information you will use the following URL. The URL will return the venue information for the given venue</div>\
	<div>\
		&nbsp;</div>\
	<div>\
		<div>\
			<a class="quad-tooltip-toggle" target="_blank" title="https://&lt;ServerAddress&gt;/api/cmxmobile/v1/venues/info/&lt;VenueId&gt;">https://&lt;ServerAddress&gt;/api/cmxmobile/v1/venues/info/&lt;VenueId&gt;</a></div>\
		<ul>\
			<li>\
				ServerAddress - The IP address the server is running on</li>\
			<li>\
				VenueId- The identifier for the venue. This can be retrieved from the client location</li>\
		</ul>\
	</div>\
	<strong>Example:</strong>\
	<div>\
		<a class="quad-tooltip-toggle" href="https://localhost/api/cmxmobile/v1/venues/info/782309123536" target="_blank" title="https://localhost/api/cmxmobile/v1/venues/info/782309123536">https://localhost/api/cmxmobile/v1/venues/info/782309123536</a></div>\
	<br />\
	<div>\
		<strong>Results:</strong></div>\
	<div>\
		<pre>\
{<br>\
  &quot;venueId&quot;: &quot;782309123536&quot;,<br>\
  &quot;streetAddress&quot;: &quot;3625 Cisco Way, San Jose, CA 95131&quot;,<br>\
  &quot;name&quot;: &quot;Cisco&quot;,<br>\
  &quot;preferredNetwork&quot;: [<br>\
    {<br>\
      &quot;ssid&quot;: &quot;alpha&quot;,<br>\
      &quot;password&quot;: &quot;&quot;<br>\
    },\
    {\
      &quot;ssid&quot;: &quot;blizzard&quot;,<br>\
      &quot;password&quot;: &quot;&quot;<br>\
    }<br>\
  ],<br>\
  &quot;floors&quot;: [<br>\
    {<br>\
      &quot;mapHierarchyString&quot;: &quot;System Campus>SJC-14>1st Floor&quot;,<br>\
      &quot;name&quot;: &quot;1st Floor&quot;,<br>\
      &quot;floorId&quot;: &quot;730297895206518931&quot;,<br>\
      &quot;venueid&quot;: &quot;782309123536&quot;,<br>\
      &quot;dimension&quot;: {<br>\
      &quot;length&quot;: &quot;185.8&quot;,<br>\
      &quot;width&quot;: &quot;295.8&quot;,<br>\
      &quot;height&quot;: &quot;10.0&quot;,<br>\
      &quot;offsetX&quot;: &quot;0.0&quot;,<br>\
      &quot;offsetY&quot;: &quot;0.0&quot;,<br>\
      &quot;unit&quot;: &quot;FEET&quot;<br>\
    }<br>\
  ]<br>\
}</pre>\
	</div>\
		<h3>\
		Venue Download</h3>\
	<div>\
		<div>\
			To download a venue image you will use the following URL. The URL will return the venue image specified</div>\
		<br />\
		<div>\
			<div>\
				<a class="quad-tooltip-toggle" target="_blank" title="https://&lt;ServerAddress&gt;/api/cmxmobile/v1/venues/image/&lt;VenueId&gt;">https://&lt;ServerAddress&gt;/api/cmxmobile/v1/venues/image/&lt;VenueId&gt;</a></div>\
			<ul>\
				<li>\
					ServerAddress - The IP address the server is running on</li>\
				<li>\
					VenueId- The identifier for the venue. This can be retrieved from the client location</li>\
			</ul>\
		</div>\
		<strong>Example:</strong>\
		<div>\
			<a class="quad-tooltip-toggle" href="https://localhost/api/cmxmobile/v1/venues/image/782309123536" target="_blank" title="https://localhost/api/cmxmobile/v1/venues/image/782309123536">https://localhost/api/cmxmobile/v1/venues/image/782309123536</a><br />\
			&nbsp;</div>\
		<div>\
			<div>\
				<strong>Results:</strong></div>\
			<div>\
				Venue image</div>\
			<div>\
				<div>\
		<h3>\
		Banners For A Zone</h3>\
	<div>\
		To get all the banners for a specific zone you will use the following URL. The URL will return JSON data for the banners</div>\
	<br />\
	<div>\
		<div>\
			<a class="quad-tooltip-toggle" target="_blank" title="https://&lt;ServerAddress&gt;/api/cmxmobile/v1/banners/info/&lt;VenueId&gt;/&lt;FloorId&gt;/&lt;ZoneId&gt;">https://&lt;ServerAddress&gt;/api/cmxmobile/v1/pois/info/&lt;VenueId&gt;/&lt;FloorId&gt;/&lt;ZoneId&gt;</a></div>\
		<ul>\
			<li>\
				ServerAddress - The IP address the server is running on</li>\
			<li>\
				VenueId- The identifier for the venue. This can be retrieved from the client location</li>\
			<li>\
				FloorId - The identifier for the floor. This can be retrieved from the client location</li>\
			<li>\
				ZoneId- The identifier for the zone. This can be retrieved from the client location</li>\
		</ul>\
	</div>\
	<strong>Example:</strong>\
	<div>\
		<a class="quad-tooltip-toggle" href="https://localhost/api/cmxmobile/v1/banners/info/782309123536/730297895206518931/78230912353603" target="_blank" title="https://localhost/api/cmxmobile/v1/pois/info/782309123536/730297895206518931/78230912353603">https://localhost/api/cmxmobile/v1/banners/info/782309123536/730297895206518931/78230912353603</a></div>\
	<div>\
		&nbsp;</div>\
	<div>\
		<strong>Results:</strong></div>\
	<div>\
		<pre>\
[<br>\
  {<br>\
    &quot;zoneid&quot;: &quot;78230912353603&quot;,<br>\
    &quot;venueid&quot;: &quot;782309123536&quot;,<br>\
    &quot;id&quot;: &quot;01&quot;,<br>\
    &quot;imageType&quot; : &quot;png&quot;,<br>\
    &quot;url&quot;: &quot;https://localhost/api/cmxmobile/v1/banners/image/782309123536/730297895206518931/78230912353603/01&quot;<br>\
  },<br>\
  {<br>\
    &quot;zoneid&quot;: &quot;78230912353603&quot;,<br>\
    &quot;venueid&quot;: &quot;782309123536&quot;,<br>\
    &quot;id&quot;: &quot;02&quot;,<br>\
    &quot;imageType&quot; : &quot;png&quot;,<br>\
    &quot;url&quot;: &quot;https://localhost/api/cmxmobile/v1/banners/image/782309123536/730297895206518931/78230912353603/02&quot;<br>\
  }<br>\
]</pre>\
	</div>\
		<h3>\
		Banner Download</h3>\
	<div>\
		<div>\
			To download a banner image you will use the following URL. The URL will return the banner image specified</div>\
		<br />\
		<div>\
			<div>\
				<a class="quad-tooltip-toggle" target="_blank" title="https://&lt;ServerAddress&gt;/api/cmxmobile/v1/venues/image/&lt;VenueId&gt;/&lt;FloorId&gt;/&lt;ZoneId&gt;/&lt;ImageId&gt;">https://&lt;ServerAddress&gt;/api/cmxmobile/v1/venues/image/&lt;VenueId&gt;/&lt;FloorId&gt;/&lt;ZoneId&gt;/&lt;ImageId&gt;</a></div>\
			<ul>\
				<li>\
					ServerAddress - The IP address the server is running on</li>\
				<li>\
					VenueId- The identifier for the venue. This can be retrieved from the client location</li>\
				<li>\
					FloorId- The identifier for the floor. This can be retrieved from the client location</li>\
				<li>\
					ZoneId- The identifier for the zone. This can be retrieved from the client location</li>\
				<li>\
					ImageId- The identifier for the image</li>\
			</ul>\
		</div>\
		<strong>Example:</strong>\
		<div>\
			<a class="quad-tooltip-toggle" href="https://localhost/api/cmxmobile/v1/banners/image/782309123536/730297895206518931/78230912353603/01" target="_blank" title="https://localhost/api/cmxmobile/v1/banners/image/782309123536/730297895206518931/78230912353603/01">https://localhost/api/cmxmobile/v1/banners/image/782309123536/730297895206518931/78230912353603/01</a><br />\
			&nbsp;</div>\
		<div>\
			<div>\
				<strong>Results:</strong></div>\
			<div>\
				Banner image</div>\
			<div>\
				<div>\
					<h3>\
						Points Of Interest For A Venue</h3>\
					<div>\
						To get all the points of interest for a specific venue you will use the following URL. The URL will return JSON data for the points of interest</div>\
					<br />\
					<div>\
						<div>\
							<a class="quad-tooltip-toggle" target="_blank" title="https://&lt;ServerAddress&gt;/api/cmxmobile/v1/pois/info/&lt;VenueId&gt;">https://&lt;ServerAddress&gt;/api/cmxmobile/v1/pois/info/&lt;VenueId&gt;</a></div>\
						<ul>\
							<li>\
								ServerAddress - The IP address the server is running on</li>\
							<li>\
								VenueId- The identifier for the venue. This can be retrieved from the client location</li>\
						</ul>\
					</div>\
					<strong>Example:</strong>\
					<div>\
						<a class="quad-tooltip-toggle" href="https://localhost/api/cmxmobile/v1/pois/info/782309123536" target="_blank" title="https://localhost/api/cmxmobile/v1/pois/info/782309123536">https://localhost/api/cmxmobile/v1/pois/info/782309123536</a></div>\
					<div>\
						&nbsp;</div>\
					<div>\
						<strong>Results:</strong></div>\
					<div>\
						<pre>\
[<br>\
  {<br>\
    &quot;floorid&quot;: &quot;730297895206518938&quot;,<br>\
    &quot;id&quot;: &quot;7167&quot;,<br>\
    &quot;name&quot;: &quot;Benbow&quot;,<br>\
    &quot;points&quot;: &quot;[{\&quot;x\&quot;:18.077657542966264,\&quot;y\&quot;:150.684289276808},{\&quot;x\&quot;:34.62762571610439,\&quot;y\&quot;:150.8},{\&quot;x\&quot;:34.50031826861871,\&quot;y\&quot;:162.371072319202},{\&quot;x\&quot;:18.586887332908976,\&quot;y\&quot;:162.371072319202}]&quot;,<br>\
    &quot;imageType&quot; : &quot;gif&quot;,<br>\
    &quot;venueid&quot;: &quot;782309123536&quot;<br>\
  },<br>\
  {<br>\
    &quot;floorid&quot;: &quot;730297895206518938&quot;,<br>\
    &quot;id&quot;: &quot;7160&quot;,<br>\
    &quot;name&quot;: &quot;Break Room&quot;,<br>\
    &quot;points&quot;: &quot;[{\&quot;x\&quot;:139.16,\&quot;y\&quot;:66.6},{\&quot;x\&quot;:177.95,\&quot;y\&quot;:66.6},{\&quot;x\&quot;:178.33,\&quot;y\&quot;:90.35},{\&quot;x\&quot;:138.78,\&quot;y\&quot;:90.19}]&quot;,<br>\
    &quot;imageType&quot; : &quot;png&quot;,<br>\
    &quot;venueid&quot;: &quot;782309123536&quot;<br>\
  },<br>\
  {<br>\
    &quot;floorid&quot;: &quot;730297895206518938&quot;,<br>\
    &quot;id&quot;: &quot;7166&quot;,<br>\
    &quot;name&quot;: &quot;Capitola&quot;,<br>\
    &quot;points&quot;: &quot;[{\&quot;x\&quot;:18.26861871419478,\&quot;y\&quot;:138.99750623441398},{\&quot;x\&quot;:33.92743475493316,\&quot;y\&quot;:138.76608478802993},{\&quot;x\&quot;:34.436664544875875,\&quot;y\&quot;:150.2214463840399},{\&quot;x\&quot;:17.759388924252068,\&quot;y\&quot;:150.10573566084787}]&quot;,<br>\
    &quot;imageType&quot; : &quot;gif&quot;,<br>\
    &quot;venueid&quot;: &quot;782309123536&quot;<br>\
  }<br>\
]</pre>\
					</div>\
	<h3>\
		MAP Information For A Venue</h3>\
	<div>\
		To download a map information you will use the following URL. The URL will return the map information for the given venue</div>\
	<div>\
		&nbsp;</div>\
	<div>\
		<div>\
			<a class="quad-tooltip-toggle" target="_blank" title="https://&lt;ServerAddress&gt;/api/cmxmobile/v1/maps/info/&lt;VenueId&gt;">https://&lt;ServerAddress&gt;/api/cmxmobile/v1/maps/info/&lt;VenueId&gt;</a></div>\
		<ul>\
			<li>\
				ServerAddress - The IP address the server is running on</li>\
			<li>\
				VenueId- The identifier for the venue. This can be retrieved from the client location</li>\
		</ul>\
	</div>\
	<strong>Example:</strong>\
	<div>\
		<a class="quad-tooltip-toggle" href="https://localhost/api/cmxmobile/v1/maps/info/782309123536" target="_blank" title="https://localhost/api/cmxmobile/v1/maps/info/782309123536">https://localhost/api/cmxmobile/v1/maps/info/782309123536</a></div>\
	<br />\
	<div>\
		<strong>Results:</strong></div>\
	<div>\
		<pre>\
[<br>\
  {<br>\
    &quot;mapHierarchyString&quot;: &quot;System Campus&gt;SJC-14&gt;1th Floor&quot;,<br>\
    &quot;floorId&quot;: &quot;730297895206518931&quot;,<br>\
    &quot;venueid&quot;: &quot;782309123536&quot;,<br>\
    &quot;dimension&quot;: {<br>\
      &quot;length&quot;: &quot;185.8&quot;,<br>\
      &quot;width&quot;: &quot;295.8&quot;,<br>\
      &quot;height&quot;: &quot;10.0&quot;,<br>\
      &quot;offsetX&quot;: &quot;0.0&quot;,<br>\
      &quot;offsetY&quot;: &quot;0.0&quot;,<br>\
      &quot;unit&quot;: &quot;FEET&quot;<br>\
    }<br>\
  },<br>\
  {<br>\
    &quot;mapHierarchyString&quot;: &quot;System Campus&gt;SJC-14&gt;2nd Floor&quot;,<br>\
    &quot;floorId&quot;: &quot;730297895206518933&quot;,<br>\
    &quot;venueid&quot;: &quot;782309123536&quot;,<br>\
    &quot;dimension&quot;: {<br>\
      &quot;length&quot;: &quot;185.8&quot;,<br>\
      &quot;width&quot;: &quot;295.8&quot;,<br>\
      &quot;height&quot;: &quot;10.0&quot;,<br>\
      &quot;offsetX&quot;: &quot;0.0&quot;,<br>\
      &quot;offsetY&quot;: &quot;0.0&quot;,<br>\
      &quot;unit&quot;: &quot;FEET&quot;<br>\
    }<br>\
  },<br>\
  {<br>\
    &quot;mapHierarchyString&quot;: &quot;System Campus&gt;SJC-14&gt;3rd Floor&quot;,<br>\
    &quot;floorId&quot;: &quot;730297895206518935&quot;,<br>\
    &quot;venueid&quot;: &quot;782309123536&quot;,<br>\
    &quot;dimension&quot;: {<br>\
      &quot;length&quot;: &quot;185.8&quot;,<br>\
      &quot;width&quot;: &quot;295.8&quot;,<br>\
      &quot;height&quot;: &quot;10.0&quot;,<br>\
      &quot;offsetX&quot;: &quot;0.0&quot;,<br>\
      &quot;offsetY&quot;: &quot;0.0&quot;,<br>\
      &quot;unit&quot;: &quot;FEET&quot;<br>\
    }<br>\
  },<br>\
  {<br>\
    &quot;mapHierarchyString&quot;: &quot;System Campus&gt;SJC-14&gt;4th Floor&quot;,<br>\
    &quot;floorId&quot;: &quot;730297895206518938&quot;,<br>\
    &quot;venueid&quot;: &quot;782309123536&quot;,<br>\
    &quot;dimension&quot;: {<br>\
      &quot;length&quot;: &quot;185.8&quot;,<br>\
      &quot;width&quot;: &quot;295.8&quot;,<br>\
      &quot;height&quot;: &quot;10.0&quot;,<br>\
      &quot;offsetX&quot;: &quot;0.0&quot;,<br>\
      &quot;offsetY&quot;: &quot;0.0&quot;,<br>\
      &quot;unit&quot;: &quot;FEET&quot;<br>\
    }<br>\
  }<br>\
]<br>\
		</pre>\
	</div>\
	<h3>\
		MAP Information For A Floor</h3>\
	<div>\
		To download a map information you will use the following URL. The URL will return the map information for the given floor</div>\
	<div>\
		&nbsp;</div>\
	<div>\
		<div>\
			<a class="quad-tooltip-toggle" target="_blank" title="https://&lt;ServerAddress&gt;/api/cmxmobile/v1/maps/info/&lt;VenueId&gt;/&lt;FloorId&gt;">https://&lt;ServerAddress&gt;/api/cmxmobile/v1/maps/info/&lt;VenueId&gt;/&lt;FloorId&gt;</a></div>\
		<ul>\
			<li>\
				ServerAddress - The IP address the server is running on</li>\
			<li>\
				VenueId- The identifier for the venue. This can be retrieved from the client location</li>\
			<li>\
				FloorId- The identifier for the floor in the venue. This can be retrieved from the client location</li>\
		</ul>\
	</div>\
	<strong>Example:</strong>\
	<div>\
		<a class="quad-tooltip-toggle" href="https://localhost/api/cmxmobile/v1/maps/info/782309123536/730297895206518938" target="_blank" title="https://localhost/api/cmxmobile/v1/maps/info/782309123536/730297895206518938">https://localhost/api/cmxmobile/v1/maps/info/782309123536/730297895206518938</a></div>\
	<br />\
	<div>\
		<strong>Results:</strong></div>\
	<div>\
		<pre>\
{<br>\
  &quot;mapHierarchyString&quot;: &quot;System Campus&gt;SJC-14&gt;4th Floor&quot;,<br>\
  &quot;floorId&quot;: &quot;730297895206518938&quot;,<br>\
  &quot;venueid&quot;: &quot;782309123536&quot;,<br>\
  &quot;dimension&quot;: {<br>\
    &quot;length&quot;: &quot;185.8&quot;,<br>\
    &quot;width&quot;: &quot;295.8&quot;,<br>\
    &quot;height&quot;: &quot;10.0&quot;,<br>\
    &quot;offsetX&quot;: &quot;0.0&quot;,<br>\
    &quot;offsetY&quot;: &quot;0.0&quot;,<br>\
    &quot;unit&quot;: &quot;FEET&quot;<br>\
  }<br>\
}</pre>\
	</div>\
	<h3>\
		MAP Download</h3>\
	<div>\
		<div>\
			To download a map image you will use the following URL. The URL will return the map image specified</div>\
		<br />\
		<div>\
			<div>\
				<a class="quad-tooltip-toggle" target="_blank" title="https://&lt;ServerAddress&gt;/api/cmxmobile/v1/maps/image/&lt;VenueId&gt;/&lt;FloorId&gt;">https://&lt;ServerAddress&gt;/api/cmxmobile/v1/maps/image/&lt;VenueId&gt;/&lt;FloorId&gt;</a></div>\
			<ul>\
				<li>\
					ServerAddress - The IP address the server is running on</li>\
				<li>\
					VenueId- The identifier for the venue. This can be retrieved from the client location</li>\
				<li>\
					FloorId- The identifier for the floor in the venue. This can be retrieved from the client location</li>\
			</ul>\
		</div>\
		<strong>Example:</strong>\
		<div>\
			<a class="quad-tooltip-toggle" href="https://localhost/api/cmxmobile/v1/maps/image/782309123536/730297895206518938" target="_blank" title="https://localhost/api/cmxmobile/v1/maps/image/782309123536/730297895206518938">https://localhost/api/cmxmobile/v1/maps/image/782309123536/730297895206518938</a><br />\
			&nbsp;</div>\
		<div>\
			<div>\
				<strong>Results:</strong></div>\
			<div>\
				Map image</div>\
			<div>\
				<div>\
					<h3>\
						Points Of Interest For A Venue</h3>\
					<div>\
						To get all the points of interest for a specific venue you will use the following URL. The URL will return JSON data for the points of interest</div>\
					<br />\
					<div>\
						<div>\
							<a class="quad-tooltip-toggle" target="_blank" title="https://&lt;ServerAddress&gt;/api/cmxmobile/v1/pois/info/&lt;VenueId&gt;">https://&lt;ServerAddress&gt;/api/cmxmobile/v1/pois/info/&lt;VenueId&gt;</a></div>\
						<ul>\
							<li>\
								ServerAddress - The IP address the server is running on</li>\
							<li>\
								VenueId- The identifier for the venue. This can be retrieved from the client location</li>\
						</ul>\
					</div>\
					<strong>Example:</strong>\
					<div>\
						<a class="quad-tooltip-toggle" href="https://localhost/api/cmxmobile/v1/pois/info/782309123536" target="_blank" title="https://localhost/api/cmxmobile/v1/pois/info/782309123536">https://localhost/api/cmxmobile/v1/pois/info/782309123536</a></div>\
					<div>\
						&nbsp;</div>\
					<div>\
						<strong>Results:</strong></div>\
					<div>\
						<pre>\
[<br>\
  {<br>\
    &quot;floorid&quot;: &quot;730297895206518938&quot;,<br>\
    &quot;id&quot;: &quot;7167&quot;,<br>\
    &quot;name&quot;: &quot;Benbow&quot;,<br>\
    &quot;points&quot;: &quot;[{\&quot;x\&quot;:18.077657542966264,\&quot;y\&quot;:150.684289276808},{\&quot;x\&quot;:34.62762571610439,\&quot;y\&quot;:150.8},{\&quot;x\&quot;:34.50031826861871,\&quot;y\&quot;:162.371072319202},{\&quot;x\&quot;:18.586887332908976,\&quot;y\&quot;:162.371072319202}]&quot;,<br>\
    &quot;imageType&quot; : &quot;gif&quot;,<br>\
    &quot;venueid&quot;: &quot;782309123536&quot;<br>\
  },<br>\
  {<br>\
    &quot;floorid&quot;: &quot;730297895206518938&quot;,<br>\
    &quot;id&quot;: &quot;7160&quot;,<br>\
    &quot;name&quot;: &quot;Break Room&quot;,<br>\
    &quot;points&quot;: &quot;[{\&quot;x\&quot;:139.16,\&quot;y\&quot;:66.6},{\&quot;x\&quot;:177.95,\&quot;y\&quot;:66.6},{\&quot;x\&quot;:178.33,\&quot;y\&quot;:90.35},{\&quot;x\&quot;:138.78,\&quot;y\&quot;:90.19}]&quot;,<br>\
    &quot;imageType&quot; : &quot;png&quot;,<br>\
    &quot;venueid&quot;: &quot;782309123536&quot;<br>\
  },<br>\
  {<br>\
    &quot;floorid&quot;: &quot;730297895206518938&quot;,<br>\
    &quot;id&quot;: &quot;7166&quot;,<br>\
    &quot;name&quot;: &quot;Capitola&quot;,<br>\
    &quot;points&quot;: &quot;[{\&quot;x\&quot;:18.26861871419478,\&quot;y\&quot;:138.99750623441398},{\&quot;x\&quot;:33.92743475493316,\&quot;y\&quot;:138.76608478802993},{\&quot;x\&quot;:34.436664544875875,\&quot;y\&quot;:150.2214463840399},{\&quot;x\&quot;:17.759388924252068,\&quot;y\&quot;:150.10573566084787}]&quot;,<br>\
    &quot;imageType&quot; : &quot;gif&quot;,<br>\
    &quot;venueid&quot;: &quot;782309123536&quot;<br>\
  }<br>\
]</pre>\
					</div>\
				</div>\
				<h3>\
					Points Of Interest For A Floor</h3>\
				<div>\
					To get all the points of interest for a specific floor you will use the following URL. The URL will return JSON data for the points of interest</div>\
				<br />\
				<div>\
					<div>\
						<a class="quad-tooltip-toggle" target="_blank" title="https://&lt;ServerAddress&gt;/api/cmxmobile/v1/pois/info/&lt;VenueId&gt;/&lt;FloorId&gt;">https://&lt;ServerAddress&gt;/api/cmxmobile/v1/pois/info/&lt;VenueId&gt;/&lt;FloorId&gt;</a></div>\
					<ul>\
						<li>\
							ServerAddress - The IP address the server is running on</li>\
						<li>\
							VenueId- The identifier for the venue. This can be retrieved from the client location</li>\
						<li>\
							FloorId- The identifier for the floor in the venue. This can be retrieved from the client location</li>\
					</ul>\
				</div>\
				<strong>Example:</strong>\
				<div>\
					<a class="quad-tooltip-toggle" href="https://localhost/api/cmxmobile/v1/pois/info/782309123536/730297895206518938" target="_blank" title="https://localhost/api/cmxmobile/v1/pois/info/782309123536/730297895206518938">https://localhost/api/cmxmobile/v1/pois/info/782309123536/730297895206518938</a></div>\
				<div>\
					&nbsp;</div>\
				<div>\
					<strong>Results:</strong></div>\
				<div>\
					<pre>\
[<br>\
  {<br>\
    &quot;floorid&quot;: &quot;730297895206518938&quot;,<br>\
    &quot;id&quot;: &quot;7167&quot;,<br>\
    &quot;name&quot;: &quot;Benbow&quot;,<br>\
    &quot;points&quot;: &quot;[{\&quot;x\&quot;:18.077657542966264,\&quot;y\&quot;:150.684289276808},{\&quot;x\&quot;:34.62762571610439,\&quot;y\&quot;:150.8},{\&quot;x\&quot;:34.50031826861871,\&quot;y\&quot;:162.371072319202},{\&quot;x\&quot;:18.586887332908976,\&quot;y\&quot;:162.371072319202}]&quot;,<br>\
    &quot;imageType&quot; : &quot;gif&quot;,<br>\
    &quot;imageId&quot; : &quot;7167&quot;,<br>\
    &quot;venueid&quot;: &quot;782309123536&quot;<br>\
  },<br>\
  {<br>\
    &quot;floorid&quot;: &quot;730297895206518938&quot;,<br>\
    &quot;id&quot;: &quot;7160&quot;,<br>\
    &quot;name&quot;: &quot;Break Room&quot;,<br>\
    &quot;points&quot;: &quot;[{\&quot;x\&quot;:139.16,\&quot;y\&quot;:66.6},{\&quot;x\&quot;:177.95,\&quot;y\&quot;:66.6},{\&quot;x\&quot;:178.33,\&quot;y\&quot;:90.35},{\&quot;x\&quot;:138.78,\&quot;y\&quot;:90.19}]&quot;,<br>\
    &quot;imageType&quot; : &quot;png&quot;,<br>\
    &quot;imageId&quot; : &quot;7160&quot;,<br>\
    &quot;venueid&quot;: &quot;782309123536&quot;<br>\
  },<br>\
  {<br>\
    &quot;floorid&quot;: &quot;730297895206518938&quot;,<br>\
    &quot;id&quot;: &quot;7166&quot;,<br>\
    &quot;name&quot;: &quot;Capitola&quot;,<br>\
    &quot;points&quot;: &quot;[{\&quot;x\&quot;:18.26861871419478,\&quot;y\&quot;:138.99750623441398},{\&quot;x\&quot;:33.92743475493316,\&quot;y\&quot;:138.76608478802993},{\&quot;x\&quot;:34.436664544875875,\&quot;y\&quot;:150.2214463840399},{\&quot;x\&quot;:17.759388924252068,\&quot;y\&quot;:150.10573566084787}]&quot;,<br>\
    &quot;imageType&quot; : &quot;gif&quot;,<br>\
    &quot;imageId&quot; : &quot;7167&quot;,<br>\
    &quot;venueid&quot;: &quot;782309123536&quot;<br>\
  }<br>\
]<br>\
</pre>\
					<h3>\
						Points Of Interest Download</h3>\
					<div>\
						To download a point of interest image you will use the following URL. The URL will return the point of interest image specified</div>\
					<br />\
					<div>\
						<div>\
							<a class="quad-tooltip-toggle" target="_blank" title="https://&lt;ServerAddress&gt;/api/cmxmobile/v1/pois/image/&lt;VenueId&gt;/&lt;FloorId&gt;">https://&lt;ServerAddress&gt;/api/cmxmobile/v1/pois/image/&lt;VenueId&gt;/&lt;PoiId&gt;</a></div>\
						<ul>\
							<li>\
								ServerAddress - The IP address the server is running on</li>\
							<li>\
								VenueId- The identifier for the venue. This can be retrieved from the client location</li>\
							<li>\
								PoiId- The identifier for the point of interest in the venue. This can be retrieved from the point of interest information</li>\
						</ul>\
					</div>\
					<strong>Example:</strong>\
					<div>\
						<a class="quad-tooltip-toggle" href="https://localhost/api/cmxmobile/v1/pois/image/782309123536/7167" target="_blank" title="https://localhost/api/cmxmobile/v1/pois/image/782309123536/7167">https://localhost/api/cmxmobile/v1/pois/image/782309123536/7167</a></div>\
					<div>\
						&nbsp;</div>\
					<div>\
						<strong>Results:</strong></div>\
					<div>\
						Point of interest image</div>\
				</div>\
			</div>\
		</div>\
		<div>\
		<h3>\
		Points Of Interest Download Using Image Id</h3>\
	<div>\
		To download a point of interest image using image ID you will use the following URL. The URL will return the point of interest image specified</div>\
	<br />\
	<div>\
		<div>\
			<a class="quad-tooltip-toggle" target="_blank" title="https://&lt;ServerAddress&gt;/api/cmxmobile/v1/pois/imageid/&lt;VenueId&gt;/&lt;ImageId&gt;">https://&lt;ServerAddress&gt;/api/cmxmobile/v1/pois/imageid/&lt;VenueId&gt;/&lt;ImageId&gt;</a></div>\
		<ul>\
			<li>\
				ServerAddress - The IP address the server is running on</li>\
			<li>\
				VenueId- The identifier for the venue. This can be retrieved from the client location</li>\
			<li>\
				ImageId- The image ID for the point of interest in the venue. This can be retrieved from the point of interest information</li>\
		</ul>\
	</div>\
	<strong>Example:</strong>\
	<div>\
		<a class="quad-tooltip-toggle" href="https://localhost/api/cmxmobile/v1/pois/imageid/782309123536/7167" target="_blank" title="https://localhost/api/cmxmobile/v1/pois/imageid/782309123536/7167">https://localhost/api/cmxmobile/v1/pois/imageid/782309123536/7167</a></div>\
	<div>\
		&nbsp;</div>\
	<div>\
		<strong>Results:</strong></div>\
	<div>\
		Point of interest image</div>\
</div>\
</div>\
</div>\
<div>\
			<h3>\
				Search</h3>\
			<div>\
				To execute a search you will use the following URL. The URL will return JSON data for the search results</div>\
			<br />\
			<div>\
				<div>\
					<a class="quad-tooltip-toggle" target="_blank" title="https://&lt;ServerAddress&gt;/api/cmxmobile/v1/pois/info/&lt;VenueId&gt;?search=&lt;KeyWord&gt;">https://&lt;ServerAddress&gt;/api/cmxmobile/v1/pois/info/&lt;VenueId&gt;?search=&lt;KeyWord&gt;</a></div>\
				<ul>\
					<li>\
						ServerAddress - The IP address the server is running on</li>\
					<li>\
						VenueId- The identifier for the venue. This can be retrieved from the client location</li>\
					<li>\
						KeyWord- Key word to be used in the search</li>\
				</ul>\
				<div>\
					The simulator supports keywords for all points of interest</div>\
				<div>\
					&nbsp;</div>\
			</div>\
			<strong>Example:</strong>\
			<div>\
				<a class="quad-tooltip-toggle" href="https://localhost/api/cmxmobile/v1/pois/info/782309123536?search=beach" target="_blank" title="https://localhost/api/cmxmobile/v1/pois/info/782309123536?search=beach">https://localhost/api/cmxmobile/v1/pois/info/782309123536?search=beach</a></div>\
			<div>\
				&nbsp;</div>\
			<div>\
				<strong>Results:</strong></div>\
			<pre>\
[<br>\
  {<br>\
    &quot;floorid&quot;: &quot;730297895206518938&quot;,<br>\
    &quot;id&quot;: &quot;7163&quot;,<br>\
    &quot;name&quot;: &quot;Newport Beach&quot;,<br>\
    &quot;points&quot;: &quot;[{\&quot;x\&quot;:265.62698917886695,\&quot;y\&quot;:150.10573566084787},{\&quot;x\&quot;:281.2858052196053,\&quot;y\&quot;:150.10573566084787},{\&quot;x\&quot;:281.66772756206234,\&quot;y\&quot;:160.75112219451373},{\&quot;x\&quot;:265.49968173138126,\&quot;y\&quot;:160.98254364089775}]&quot;,<br>\
    &quot;venueid&quot;: &quot;782309123536&quot;<br>\
  },<br>\
  {<br>\
    &quot;floorid&quot;: &quot;730297895206518938&quot;,<br>\
    &quot;id&quot;: &quot;7158&quot;,<br>\
    &quot;name&quot;: &quot;Pebble Beach&quot;,<br>\
    &quot;points&quot;: &quot;[{\&quot;x\&quot;:201.20942075111392,\&quot;y\&quot;:70.61246882793017},{\&quot;x\&quot;:219.41438574156587,\&quot;y\&quot;:70.49675810473816},{\&quot;x\&quot;:219.1597708465945,\&quot;y\&quot;:97.80448877805486},{\&quot;x\&quot;:201.46403564608528,\&quot;y\&quot;:97.68877805486285}]&quot;,<br>\
    &quot;venueid&quot;: &quot;782309123536&quot;<br>\
  },<br>\
  {<br>\
    &quot;floorid&quot;: &quot;730297895206518938&quot;,<br>\
    &quot;id&quot;: &quot;7159&quot;,<br>\
    &quot;name&quot;: &quot;Sunset Beach&quot;,<br>\
    &quot;points&quot;: &quot;[{\&quot;x\&quot;:166.58179503500955,\&quot;y\&quot;:71.53815461346633},{\&quot;x\&quot;:179.439847231063,\&quot;y\&quot;:71.42244389027432},{\&quot;x\&quot;:179.69446212603435,\&quot;y\&quot;:96.30024937655861},{\&quot;x\&quot;:166.8364099299809,\&quot;y\&quot;:96.30024937655861}]&quot;,<br>\
    &quot;venueid&quot;: &quot;782309123536&quot;<br>\
  }<br>\
]</pre>\
		</div>\
	</div>\
</div>\
<div>\
	<div>\
		<h3>\
			Navigation</h3>\
		<div>\
			To get the navigation points from a sourc to a destination you will use the following URL. The URL will return JSON data for the points of interest</div>\
		<div>\
			&nbsp;</div>\
		<div>\
			<a class="quad-tooltip-toggle" target="_blank" title="https://&lt;ServerAddress&gt;/api/cmxmobile/v1/routes/clients/&lt;DeviceId&gt;?destpoit=&lt;DestPoi&gt;">https://&lt;ServerAddress&gt;/api/cmxmobile/v1/routes/clients/&lt;DeviceId&gt;?destpoi=&lt;DestPoi&gt;</a></div>\
		<ul>\
			<li>\
				ServerAddress - The IP address the server is running on</li>\
			<li>\
				DeviceId- This could be any ID which can be used to identify a client and can be mapped to a MAC address in the CMX Mobile App Server</li>\
			<li>\
				DestPoi- Destination point of interest ID</li>\
		</ul>\
		<div>\
			The current POC Server only has 1st floor routes to PoiNames for Sandman, Kingpin and Dr. Doom</div>\
		The current POC Server only has 2nd floor routes to PoiNames for Eddie Van Halen, Jerry Garcia and Bob Dylan\
		<div>\
			The current POC Server only has 3rd floor routes to PoiNames for Rickey Jackson, Jimmy_Graham and Drew Brees</div>\
		<div>\
			The current POC Server only has 4th floor routes to PoiNames for Dillon Beach, Key West and Miami Beach</div>\
		<div>\
			&nbsp;</div>\
		<div>\
			<strong>Example:</strong></div>\
		<div>\
			<div>\
				<a class="quad-tooltip-toggle" href="https://localhost/api/cmxmobile/v1/routes/clients/000ab8ffe9ec?destpoi=7154" target="_blank" title="https://localhost/api/cmxmobile/v1/routes/clients/000ab8ffe9ec?destpoi=7154">https://localhost/api/cmxmobile/v1/routes/clients/000ab8ffe9ec?destpoi=7154</a></div>\
		</div>\
		<br />\
		<div>\
			<strong>Results:</strong></div>\
		<pre>\
[<br>\
  {<br>\
    &quot;x&quot;: 95.70337364735836,<br>\
    &quot;y&quot;: 30.909226932668332<br>\
  },<br>\
  {<br>\
    &quot;x&quot;: 66.42266072565245,<br>\
    &quot;y&quot;: 31.14064837905238<br>\
  },<br>\
  {<br>\
    &quot;x&quot;: 37.14194780394653,<br>\
    &quot;y&quot;: 30.56209476309226<br>\
  },<br>\
  {<br>\
    &quot;x&quot;: 36.37810311903246,<br>\
    &quot;y&quot;: 16.676807980049887<br>\
  }<br>\
]</pre>\
	</div>\
</div>\
');