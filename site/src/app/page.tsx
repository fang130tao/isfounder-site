'use client'

import { motion } from 'framer-motion'
import { useState, useEffect } from 'react'

// 流动形状组件 - 艺术化背景元素
const FlowingShape = ({ delay, duration, color, size, top, left }: {
  delay: number
  duration: number
  color: string
  size: number
  top: string
  left: string
}) => (
  <motion.div
    className="absolute rounded-full blur-3xl opacity-30"
    style={{
      width: size,
      height: size,
      background: color,
      top,
      left,
    }}
    animate={{
      scale: [1, 1.2, 1],
      x: [0, 30, 0],
      y: [0, -20, 0],
      rotate: [0, 180, 360],
    }}
    transition={{
      duration,
      delay,
      repeat: Infinity,
      ease: "easeInOut"
    }}
  />
)

// 艺术线条组件
const ArtisticLine = ({ delay }: { delay: number }) => (
  <motion.div
    className="absolute h-px bg-gradient-to-r from-transparent via-purple-400/50 to-transparent"
    style={{ width: '100%' }}
    initial={{ scaleX: 0, opacity: 0 }}
    animate={{ scaleX: 1, opacity: 1 }}
    transition={{ duration: 2, delay }}
  />
)

// 插画风格的圆形装饰
const CircleDecoration = ({ size, color, top, left, delay }: {
  size: number
  color: string
  top: string
  left: string
  delay: number
}) => (
  <motion.div
    className="absolute rounded-full border-2"
    style={{
      width: size,
      height: size,
      borderColor: color,
      top,
      left,
    }}
    initial={{ scale: 0, rotate: 0 }}
    animate={{ scale: 1, rotate: 360 }}
    transition={{ duration: 1.5, delay, ease: "easeOut" }}
  />
)

// 艺术化的导航栏
const Navbar = () => {
  const [scrolled, setScrolled] = useState(false)

  useEffect(() => {
    const handleScroll = () => setScrolled(window.scrollY > 50)
    window.addEventListener('scroll', handleScroll)
    return () => window.removeEventListener('scroll', handleScroll)
  }, [])

  return (
    <motion.nav
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-500 ${
        scrolled ? 'backdrop-blur-xl bg-white/5 py-4' : 'py-6'
      }`}
      initial={{ y: -100, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      transition={{ duration: 0.8, ease: "easeOut" }}
    >
      <div className="max-w-7xl mx-auto px-6 flex justify-between items-center">
        <motion.div
          className="text-2xl font-light tracking-widest"
          whileHover={{ scale: 1.05 }}
          style={{
            background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
            WebkitBackgroundClip: 'text',
            WebkitTextFillColor: 'transparent',
          }}
        >
          ARTISTRY
        </motion.div>
        <div className="flex gap-8">
          {['探索', '作品', '关于', '联系'].map((item, index) => (
            <motion.a
              key={item}
              href="#"
              className="text-gray-400 hover:text-white transition-all duration-300 relative group text-sm tracking-wider"
              whileHover={{ y: -2 }}
              initial={{ opacity: 0, y: -20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: index * 0.1 + 0.3 }}
            >
              {item}
              <motion.span
                className="absolute -bottom-1 left-0 h-0.5 bg-gradient-to-r from-purple-400 to-pink-400"
                initial={{ width: 0 }}
                whileHover={{ width: '100%' }}
                transition={{ duration: 0.3 }}
              />
            </motion.a>
          ))}
        </div>
      </div>
    </motion.nav>
  )
}

// Hero 区域 - 艺术化设计
const HeroSection = () => (
  <section className="min-h-screen flex items-center justify-center relative overflow-hidden pt-20">
    {/* 艺术化背景 */}
    <div className="absolute inset-0 pointer-events-none overflow-hidden">
      <FlowingShape delay={0} duration={8} color="linear-gradient(135deg, #667eea 0%, #764ba2 100%)" size={500} top="10%" left="5%" />
      <FlowingShape delay={1} duration={10} color="linear-gradient(135deg, #f093fb 0%, #f5576c 100%)" size={400} top="60%" left="70%" />
      <FlowingShape delay={2} duration={12} color="linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)" size={350} top="30%" left="80%" />
      <FlowingShape delay={1.5} duration={9} color="linear-gradient(135deg, #fa709a 0%, #fee140 100%)" size={300} top="70%" left="20%" />

      {/* 艺术线条 */}
      <div className="absolute top-1/4 left-0 w-full">
        <ArtisticLine delay={0.5} />
      </div>
      <div className="absolute top-3/4 left-0 w-full">
        <ArtisticLine delay={1} />
      </div>

      {/* 圆形装饰 */}
      <CircleDecoration size={100} color="rgba(167, 139, 250, 0.3)" top="15%" left="10%" delay={0.8} />
      <CircleDecoration size={60} color="rgba(236, 72, 153, 0.3)" top="25%" left="85%" delay={1.2} />
      <CircleDecoration size={80} color="rgba(59, 130, 246, 0.3)" top="75%" left="15%" delay={1.5} />
    </div>

    <div className="max-w-6xl mx-auto px-6 text-center relative z-10">
      <motion.div
        initial={{ opacity: 0, y: 30 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 1, delay: 0.2 }}
        className="mb-12"
      >
        <motion.div
          className="inline-flex items-center gap-3 px-6 py-3 rounded-full border border-purple-400/30 bg-purple-500/10 backdrop-blur-sm"
          whileHover={{ scale: 1.05, borderColor: 'rgba(167, 139, 250, 0.6)' }}
        >
          <motion.div
            className="w-2 h-2 rounded-full bg-purple-400"
            animate={{ scale: [1, 1.5, 1] }}
            transition={{ duration: 2, repeat: Infinity }}
          />
          <span className="text-sm text-purple-300 tracking-wider">探索无限可能</span>
        </motion.div>
      </motion.div>

      <motion.h1
        className="text-7xl md:text-9xl font-extralight mb-8 leading-tight tracking-tight"
        initial={{ opacity: 0, y: 50 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 1, delay: 0.4 }}
      >
        <span className="block text-white mb-2">创意</span>
        <motion.span
          className="block"
          style={{
            background: 'linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f093fb 100%)',
            WebkitBackgroundClip: 'text',
            WebkitTextFillColor: 'transparent',
          }}
          animate={{
            backgroundPosition: ['0% 50%', '100% 50%', '0% 50%'],
          }}
          transition={{ duration: 5, repeat: Infinity, ease: 'linear' }}
        >
          无界限
        </motion.span>
      </motion.h1>

      <motion.p
        className="text-xl md:text-2xl text-gray-400 mb-16 max-w-2xl mx-auto leading-relaxed font-light"
        initial={{ opacity: 0, y: 50 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 1, delay: 0.6 }}
      >
        在艺术与技术的交汇处，
        <br />
        我们创造令人惊叹的数字体验
      </motion.p>

      <motion.div
        className="flex flex-col sm:flex-row gap-6 justify-center items-center"
        initial={{ opacity: 0, y: 50 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 1, delay: 0.8 }}
      >
        <motion.button
          className="group relative px-10 py-4 rounded-full overflow-hidden"
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
        >
          <div className="absolute inset-0 bg-gradient-to-r from-purple-600 via-pink-500 to-purple-600 opacity-80 group-hover:opacity-100 transition-opacity" />
          <div className="absolute inset-0 bg-gradient-to-r from-purple-600 via-pink-500 to-purple-600 blur-xl opacity-50 group-hover:opacity-75 transition-opacity" />
          <span className="relative text-white font-medium tracking-wider">开始探索</span>
        </motion.button>

        <motion.button
          className="px-10 py-4 rounded-full border border-gray-600 hover:border-purple-400 text-gray-300 hover:text-white transition-all duration-300 backdrop-blur-sm"
          whileHover={{ scale: 1.05, y: -2 }}
          whileTap={{ scale: 0.95 }}
        >
          查看作品
        </motion.button>
      </motion.div>

      {/* 滚动提示 */}
      <motion.div
        className="absolute bottom-10 left-1/2 transform -translate-x-1/2"
        animate={{ y: [0, 15, 0] }}
        transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
      >
        <div className="w-8 h-14 rounded-full border-2 border-gray-600 flex justify-center pt-2">
          <motion.div
            className="w-1.5 h-3 rounded-full bg-purple-400"
            animate={{ y: [0, 12, 0], opacity: [1, 0.5, 1] }}
            transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
          />
        </div>
      </motion.div>
    </div>
  </section>
)

// 艺术作品卡片组件
const ArtworkCard = ({ title, category, delay }: {
  title: string
  category: string
  delay: number
}) => (
  <motion.div
    className="group relative overflow-hidden rounded-3xl cursor-pointer"
    initial={{ opacity: 0, y: 60 }}
    whileInView={{ opacity: 1, y: 0 }}
    viewport={{ once: true }}
    transition={{ duration: 0.7, delay }}
    whileHover={{ y: -10 }}
  >
    <motion.div
      className="aspect-[4/5] bg-gradient-to-br from-purple-500/20 via-pink-500/20 to-blue-500/20 backdrop-blur-xl border border-white/10 group-hover:border-purple-400/50 transition-all duration-500 rounded-3xl"
      whileHover={{ scale: 1.02 }}
    />
    <div className="absolute inset-0 p-6 flex flex-col justify-end opacity-0 group-hover:opacity-100 transition-opacity duration-500">
      <div className="backdrop-blur-xl bg-black/40 rounded-2xl p-4">
        <p className="text-purple-400 text-sm tracking-wider mb-2">{category}</p>
        <h3 className="text-white text-xl font-medium">{title}</h3>
      </div>
    </div>
  </motion.div>
)

// 作品展示区域
const PortfolioSection = () => {
  const artworks = [
    { title: '数字梦境', category: '插画' },
    { title: '流动的形态', category: '抽象艺术' },
    { title: '光的轨迹', category: '数字绘画' },
    { title: '未来城市', category: '概念设计' },
    { title: '星际探索', category: '科幻插画' },
    { title: '梦境花园', category: '艺术创作' },
  ]

  return (
    <section className="py-32 relative">
      {/* 装饰性背景 */}
      <div className="absolute top-0 left-0 w-full h-full pointer-events-none overflow-hidden">
        <motion.div
          className="absolute top-20 right-10 w-64 h-64 rounded-full bg-purple-500/10 blur-3xl"
          animate={{ scale: [1, 1.2, 1], rotate: [0, 180, 360] }}
          transition={{ duration: 10, repeat: Infinity }}
        />
        <motion.div
          className="absolute bottom-20 left-10 w-48 h-48 rounded-full bg-pink-500/10 blur-3xl"
          animate={{ scale: [1, 1.3, 1], rotate: [360, 180, 0] }}
          transition={{ duration: 12, repeat: Infinity }}
        />
      </div>

      <div className="max-w-7xl mx-auto px-6 relative z-10">
        <motion.div
          className="text-center mb-20"
          initial={{ opacity: 0, y: 50 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8 }}
        >
          <h2 className="text-6xl md:text-7xl font-extralight mb-6 tracking-tight">
            <span className="text-white">精选</span>
            <br />
            <span
              style={{
                background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
                WebkitBackgroundClip: 'text',
                WebkitTextFillColor: 'transparent',
              }}
            >
              作品
            </span>
          </h2>
          <p className="text-xl text-gray-400 max-w-2xl mx-auto font-light">
            每一件作品都是创意与技术的完美融合
          </p>
        </motion.div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {artworks.map((artwork, index) => (
            <ArtworkCard key={index} {...artwork} delay={index * 0.15} />
          ))}
        </div>

        <motion.div
          className="text-center mt-16"
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true }}
          transition={{ delay: 0.5 }}
        >
          <motion.button
            className="px-12 py-4 rounded-full border-2 border-purple-400/50 text-purple-300 hover:bg-purple-500/20 transition-all duration-300 tracking-wider text-sm"
            whileHover={{ scale: 1.05, borderColor: 'rgba(167, 139, 250, 0.8)' }}
            whileTap={{ scale: 0.95 }}
          >
            查看全部作品
          </motion.button>
        </motion.div>
      </div>
    </section>
  )
}

// 艺术理念区域
const PhilosophySection = () => (
  <section className="py-32 relative overflow-hidden">
    <div className="max-w-5xl mx-auto px-6 text-center relative z-10">
      <motion.div
        initial={{ opacity: 0, y: 50 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true }}
        transition={{ duration: 0.8 }}
      >
        <h2 className="text-5xl md:text-6xl font-extralight mb-12 leading-tight">
          <span className="text-white">艺术的</span>
          <span
            style={{
              background: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
              WebkitBackgroundClip: 'text',
              WebkitTextFillColor: 'transparent',
            }}
          >
            {' '}灵魂
          </span>
        </h2>

        <motion.div
          className="space-y-8"
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true }}
          transition={{ delay: 0.3 }}
        >
          <p className="text-2xl md:text-3xl text-gray-300 leading-relaxed font-light">
            "在数字的海洋中，
            <br />
            <span className="text-white">我们用创意编织梦想</span>"
          </p>

          <div className="flex justify-center gap-8 mt-12">
            {['创新', '激情', '灵感'].map((word, index) => (
              <motion.span
                key={word}
                className="text-gray-500 text-lg tracking-widest"
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: 0.5 + index * 0.2 }}
              >
                {word}
              </motion.span>
            ))}
          </div>
        </motion.div>
      </motion.div>
    </div>
  </section>
)

// CTA 区域
const CTASection = () => (
  <section className="py-32 relative overflow-hidden">
    {/* 装饰性背景 */}
    <div className="absolute inset-0 pointer-events-none">
      <FlowingShape delay={0} duration={10} color="linear-gradient(135deg, #667eea 0%, #764ba2 100%)" size={600} top="50%" left="50%" />
    </div>

    <div className="max-w-4xl mx-auto px-6 text-center relative z-10">
      <motion.div
        initial={{ opacity: 0, y: 50 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true }}
        transition={{ duration: 0.8 }}
      >
        <h2 className="text-5xl md:text-6xl font-extralight mb-8 leading-tight">
          <span className="text-white">准备好开启</span>
          <br />
          <span
            style={{
              background: 'linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f093fb 100%)',
              WebkitBackgroundClip: 'text',
              WebkitTextFillColor: 'transparent',
            }}
          >
            创意之旅
          </span>
          <span className="text-white">了吗？</span>
        </h2>

        <motion.button
          className="group relative px-14 py-5 rounded-full overflow-hidden mt-8"
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ delay: 0.3 }}
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
        >
          <div className="absolute inset-0 bg-gradient-to-r from-purple-600 via-pink-500 to-purple-600 opacity-80 group-hover:opacity-100 transition-opacity" />
          <div className="absolute inset-0 bg-gradient-to-r from-purple-600 via-pink-500 to-purple-600 blur-xl opacity-50 group-hover:opacity-75 transition-opacity" />
          <span className="relative text-white font-medium tracking-wider text-lg">开始创作</span>
        </motion.button>
      </motion.div>
    </div>
  </section>
)

// Footer
const Footer = () => (
  <footer className="py-16 border-t border-white/10">
    <div className="max-w-7xl mx-auto px-6">
      <div className="flex flex-col md:flex-row justify-between items-center gap-8">
        <motion.div
          className="text-3xl font-light tracking-widest"
          style={{
            background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
            WebkitBackgroundClip: 'text',
            WebkitTextFillColor: 'transparent',
          }}
          whileHover={{ scale: 1.05 }}
        >
          ARTISTRY
        </motion.div>

        <div className="flex gap-8">
          {['探索', '作品', '关于', '联系'].map((item) => (
            <motion.a
              key={item}
              href="#"
              className="text-gray-500 hover:text-white transition-colors text-sm tracking-wider"
              whileHover={{ y: -2 }}
            >
              {item}
            </motion.a>
          ))}
        </div>

        <div className="text-gray-500 text-sm">
          © 2024 Artistry. All rights reserved.
        </div>
      </div>
    </div>
  </footer>
)

export default function Home() {
  return (
    <main className="min-h-screen">
      <Navbar />
      <HeroSection />
      <PortfolioSection />
      <PhilosophySection />
      <CTASection />
      <Footer />
    </main>
  )
}