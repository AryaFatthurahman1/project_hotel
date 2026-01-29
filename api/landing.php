<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>The Emerald Imperial | Luxury Hotel & Resort</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Montserrat:wght@300;400;600&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #D4AF37;
            --secondary: #1B3022;
            --dark: #0F1B14;
            --light: #F4F4F4;
            --gold-gradient: linear-gradient(135deg, #D4AF37 0%, #F1D382 50%, #B8860B 100%);
        }

        body, html {
            margin: 0;
            padding: 0;
            font-family: 'Montserrat', sans-serif;
            background-color: var(--dark);
            color: white;
            scroll-behavior: smooth;
            overflow-x: hidden;
        }

        h1, h2, h3 {
            font-family: 'Playfair Display', serif;
        }

        .hero {
            height: 100vh;
            background: linear-gradient(rgba(0,0,0,0.5), rgba(15, 27, 20, 0.9)), 
                        url('https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&q=80&w=1920');
            background-size: cover;
            background-position: center;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
            padding: 0 20px;
        }

        .logo-icon {
            color: var(--primary);
            font-size: 4rem;
            margin-bottom: 1rem;
            filter: drop-shadow(0 0 10px rgba(212, 175, 55, 0.5));
        }

        .hero h1 {
            font-size: 4rem;
            letter-spacing: 12px;
            margin-bottom: 0.5rem;
            text-transform: uppercase;
            font-weight: 400;
        }

        .hero p {
            font-size: 1.2rem;
            color: var(--primary);
            letter-spacing: 4px;
            text-transform: uppercase;
            margin-bottom: 2rem;
        }

        .btn-gold {
            background: var(--gold-gradient);
            color: var(--dark);
            padding: 15px 40px;
            border-radius: 50px;
            text-decoration: none;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 2px;
            transition: all 0.3s ease;
            border: none;
            box-shadow: 0 10px 20px rgba(0,0,0,0.3);
        }

        .btn-gold:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 30px rgba(212, 175, 55, 0.3);
        }

        .api-status {
            position: absolute;
            bottom: 30px;
            font-size: 0.8rem;
            color: rgba(255,255,255,0.4);
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .status-dot {
            width: 8px;
            height: 8px;
            background-color: #4CAF50;
            border-radius: 50%;
            box-shadow: 0 0 5px #4CAF50;
        }

        .content-section {
            padding: 100px 50px;
            max-width: 1200px;
            margin: 0 auto;
            text-align: center;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 30px;
            margin-top: 50px;
        }

        .card {
            background: rgba(255,255,255,0.03);
            border: 1px border rgba(212, 175, 55, 0.1);
            padding: 40px;
            border-radius: 20px;
            transition: all 0.3s ease;
        }

        .card:hover {
            background: rgba(255,255,255,0.05);
            border-color: var(--primary);
            transform: translateY(-10px);
        }

        .card h3 {
            color: var(--primary);
            margin-bottom: 15px;
        }

        .card p {
            line-height: 1.6;
            color: rgba(255,255,255,0.7);
        }

        footer {
            padding: 50px;
            text-align: center;
            background: #080e0a;
            color: rgba(255,255,255,0.5);
            font-size: 0.9rem;
        }

        .highlight {
            color: var(--primary);
            font-weight: bold;
        }

        @media (max-width: 768px) {
            .hero h1 { font-size: 2.5rem; letter-spacing: 6px; }
            .hero p { font-size: 1rem; }
        }
    </style>
</head>
<body>

    <section class="hero">
        <div class="logo-icon">✨</div>
        <h1>The Emerald Imperial</h1>
        <p>Kemewahan Dalam Setiap Detail</p>
        <a href="#about" class="btn-gold">Jelajahi Sekarang</a>
        
        <div class="api-status">
            <div class="status-dot"></div>
            API System: <span class="highlight">Online & Active</span>
        </div>
    </section>

    <section id="about" class="content-section">
        <h2>Selamat Datang</h2>
        <p>Pengalaman menginap yang tak terlupakan dengan layanan kelas dunia di jantung kota Jakarta.</p>
        
        <div class="grid">
            <div class="card">
                <h3>Suite Mewah</h3>
                <p>Kamar dengan desain elegan, fasilitas modern, dan pemandangan kota yang spektakuler.</p>
            </div>
            <div class="card">
                <h3>Kuliner Eksklusif</h3>
                <p>Nikmati hidangan dari chef ternama dengan bahan-bahan terbaik dari seluruh penjuru dunia.</p>
            </div>
            <div class="card">
                <h3>Spa & Relaksasi</h3>
                <p>Manjakan diri Anda dengan perawatan tradisional dan modern di pusat kebugaran kami.</p>
            </div>
        </div>
    </section>

    <footer>
        <p>&copy; 2026 Muhammad Arya Fatthurahman - 2023230006. All Rights Reserved.</p>
        <p>Luxury Hotel Management System | Cloud API v1.2.0</p>
    </footer>

</body>
</html>
