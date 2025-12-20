function ipToLong(ip) {
    return ip.split('.').reduce((acc, octet) => (acc << 8) + parseInt(octet, 10), 0) >>> 0;
}

function longToIp(long) {
    return [ (long >>> 24) & 0xFF, (long >>> 16) & 0xFF, (long >>> 8) & 0xFF, long & 0xFF ].join('.');
}

function getIpClass(ipStr) {
    const first = parseInt(ipStr.split('.')[0]);
    if (first >= 1 && first <= 126) return "A";
    if (first >= 128 && first <= 191) return "B";
    if (first >= 192 && first <= 223) return "C";
    if (first >= 224 && first <= 239) return "D (Multicast)";
    if (first >= 240 && first <= 255) return "E (Experimental)";
    return "Unknown/Loopback";
}

function calculateSubnet() {
    const ipStr = document.getElementById('ip').value.trim();
    const cidr = parseInt(document.getElementById('cidr').value);
    
    // Валидация IP
    const ipRegex = /^(\d{1,3}\.){3}\d{1,3}$/;
    if (!ipRegex.test(ipStr)) {
        alert("Введіть корректний IP (наприклад: 192.168.0.1)");
        return;
    }

    const ipLong = ipToLong(ipStr);
    
    // Расчет маски на основе CIDR
    const maskLong = (cidr === 0) ? 0 : (0xFFFFFFFF << (32 - cidr)) >>> 0;
    const maskStr = longToIp(maskLong); // Формат x.x.x.x
    
    const networkLong = (ipLong & maskLong) >>> 0;
    const broadcastLong = (networkLong | (~maskLong)) >>> 0;
    
    // Расчет хостов
    let hosts = 0;
    if (cidr < 31) hosts = Math.pow(2, 32 - cidr) - 2;
    else if (cidr === 31) hosts = 2; // Point-to-point
    else hosts = 1; // /32

    const resultsDiv = document.getElementById('results');
    resultsDiv.innerHTML = `
        <div class="res-line"><span class="label">Клас IP:</span> <span class="value">${getIpClass(ipStr)}</span></div>
        <div class="res-line"><span class="label">Маска (десяткова):</span> <span class="value">${maskStr}</span></div>
        <div class="res-line"><span class="label">Маска (CIDR):</span> <span class="value">/${cidr}</span></div>
        <div class="res-line"><span class="label">Адреса мережі:</span> <span class="value">${longToIp(networkLong)}</span></div>
        <div class="res-line"><span class="label">Broadcast:</span> <span class="value">${longToIp(broadcastLong)}</span></div>
        <div class="res-line"><span class="label">Диапазон хостів:</span> <span class="value">${cidr < 31 ? longToIp(networkLong + 1) + ' - ' + longToIp(broadcastLong - 1) : 'N/A'}</span></div>
        <div class="res-line"><span class="label">Всього хостів:</span> <span class="value">${hosts.toLocaleString()}</span></div>
    `;
}
