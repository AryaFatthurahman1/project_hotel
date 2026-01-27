/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  images: {
    domains: [
      'images.unsplash.com',
      'via.placeholder.com',
      'kilimanjaro.iixcp.rumahweb.net',
      'localhost',
    ],
    remotePatterns: [
      {
        protocol: 'https',
        hostname: '**',
      },
    ],
  },
  env: {
    API_BASE_URL: process.env.NEXT_PUBLIC_API_URL || 'https://kilimanjaro.iixcp.rumahweb.net/api',
  },
}

module.exports = nextConfig
