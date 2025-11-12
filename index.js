# SQL Injection
alert tcp any any -> any 80 (msg:"DVWA SQL Injection - UNION SELECT"; flow:established,to_server; content:"union", nocase; content:"select", nocase, distan>

alert tcp any any -> any 80 (msg:"DVWA SQL Injection - Comment syntax"; flow:established,to_server; content:"--"; content:"#"; classtype:web-application-at>

alert tcp any any -> any 80 (msg:"DVWA SQL Injection - DROP TABLE"; flow:established,to_server; content:"drop", nocase; content:"table", nocase, distance 0>

# SQL Injection Blind
alert tcp any any -> any 80 (msg:"DVWA SQL Injection Blind"; flow:established,to_server; content:"substring", nocase; classtype:web-application-attack; sid>

# XSS DOM
alert tcp any any -> any 80 (msg:"DVWA XSS DOM - SVG tag"; flow:established,to_server; content:"svg", nocase; classtype:web-application-attack; sid:1000005>

alert tcp any any -> any 80 (msg:"DVWA XSS DOM - onload event"; flow:established,to_server; content:"onload", nocase; classtype:web-application-attack; sid>

alert tcp any any -> any 80 (msg:"DVWA XSS DOM - iframe injection"; flow:established,to_server; content:"iframe", nocase; classtype:web-application-attack;>

# XSS Reflect
alert tcp any any -> any 80 (msg:"DVWA XSS reflected - literal <script>"; flow:established,to_server; content:"script", nocase; classtype:web-application-a>

alert tcp any any -> any 80 (msg:"DVWA XSS reflected - encoded %3cscript%3e in URI"; flow:established,to_server; http_uri; content:"%3cscript%3e", nocase; >

# XSS Stored
alert tcp any any -> any 80 (msg:"CUSTOM XSS STORED - <img ... onerror> in mtxMessage"; flow:to_server,established; content:"mtxMessage=", nocase; pcre:"/(>

alert tcp any any -> any 80 (msg:"CUSTOM XSS STORED - <img ... onerror> in txtName"; flow:to_server,established; content:"txtName=", nocase; pcre:"/(?:%3C|>

alert tcp any any -> any 80 (msg:"CUSTOM XSS STORED - event handler (onerror/onload/on*) in mtxMessage or txtName"; flow:to_server,established; content:"mt>

# CSRF
alert http any any -> any any (msg:"CSRF CHAIN - XHR GET to DVWA CSRF endpoint"; flow:to_server,established; http_uri; content:"/DVWA/vulnerabilities/csrf/>

alert http any any -> any any (msg:"CSRF CHAIN - password change via URI (password_new+Change+user_token)"; flow:to_server,established; http_uri; content:">
