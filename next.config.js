/** @type {import('next').NextConfig} */

const nextConfig = {
  reactStrictMode: true,
  webpack: (config, context) => {
    config.module.rules.push({
      test: /\.(lua)$/i,
      type: "asset/source",
    });

    config.module.rules.push({
      test: /\.svg$/i,
      issuer: /\.[jt]sx?$/,
      use: ['@svgr/webpack'],
    })

    config.watchOptions = {
      poll: 1000,
      aggregateTimeout: 300
    }

    config.resolve.fallback = {
      ...config.resolve.fallback,
      path: false,
      fs: false,
      child_process: false,
      crypto: false,
      url: false,
      module: false,
    }

    return config
  }
}

module.exports = nextConfig
