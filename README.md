# Ubuntu 24.04 Router Gateway Configuration

Konfigurasi otomatis untuk menjadikan Ubuntu sebagai **Router Gateway** menggunakan dua interface jaringan:

* **ens33 → WAN (DHCP / Internet)**
* **ens34 → LAN (Static 192.168.5.1/24)**

Script ini dibuat untuk mempermudah deployment lingkungan jaringan pada lab atau virtualisasi (VMware/VirtualBox).

---

##  Fitur Utama

### 1. Konfigurasi Netplan

* ens33 DHCP (WAN)
* ens34 Static IP (LAN)

### 2. Routing & NAT

* Enable IPv4 forwarding
* NAT Masquerading via iptables
* Forwarding LAN → WAN & WAN → LAN

### 3. Persistent Firewall Rules

* Menyimpan iptables melalui `iptables-persistent`

### 4. DHCP Server

* Range: **192.168.5.100 – 192.168.5.200**
* DNS default: **8.8.8.8, 1.1.1.1**
* Autostart service setelah reboot

### 5. Fully Automated (Tanpa `nano`)

* Semua konfigurasi menggunakan `tee`
* Aman untuk dijalankan sebagai installer

---

## 📂 Struktur Script

```
router.sh
├── Update System
├── Configure Netplan
├── Enable IPv4 Forwarding
├── Configure NAT (iptables)
├── Install iptables-persistent
├── Configure DHCP Server
└── Verification Commands
```

---

## 🛠️ Kebutuhan Sistem

| Komponen  | Minimal                              |
| --------- | ------------------------------------ |
| OS        | Ubuntu 22.04 / 24.04                 |
| Interface | ens33 (WAN), ens34 (LAN)             |
| Paket     | isc-dhcp-server, iptables-persistent |
| Hak akses | sudo                                 |

> Jika interface Anda berbeda, silakan sesuaikan sebelum menjalankan script.

---

##  Cara Menjalankan Script

1. Download repository ini
2. Jadikan file dapat dieksekusi:

```
chmod +x router.sh
```

3. Jalankan dengan hak akses root:

```
sudo ./router.sh
```

4. Verifikasi router berjalan:

```
ip a
ip route
iptables -t nat -L -n
```

Jika client pada interface ens34 mendapatkan IP dan akses internet → router berhasil dikonfigurasi.

---

##  Arsitektur Jaringan

```
        INTERNET
            │
        [ ens33 ]
       Ubuntu Router
        [ ens34 ]
            │
       LAN / Clients
            │
 DHCP Range: 192.168.5.100-200
```

---

##  Pengujian

### 1. Cek DHCP Server

```
systemctl status isc-dhcp-server
```

### 2. Cek IP Client

Pastikan client mendapatkan IP:

```
192.168.5.100 – 192.168.5.200
```

### 3. Cek Internet Client

```
ping google.com
```

Jika berhasil → router dan NAT berfungsi.

---

## 📄 Lisensi

Script ini bebas digunakan untuk keperluan edukasi, penelitian, dan produksi.

---

Dikembangkan oleh: Adit Setya Nugroho
