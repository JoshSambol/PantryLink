import { Container, Title, Text, Button, Center, Image, Flex, Paper, Group, Badge, Stack, Box, Grid, SimpleGrid } from '@mantine/core'
import { useNavigate } from 'react-router-dom'
import appstore from '../assets/appstore.svg'
import Logo from '../assets/Logo.png'
// Import Product Mockups
import mockup1 from '../assets/Product Mockups/IMG_5532-left.png'
import mockup2 from '../assets/Product Mockups/IMG_5533-portrait.png'
import mockup3 from '../assets/Product Mockups/IMG_5534-portrait.png'
import mockup4 from '../assets/Product Mockups/IMG_5535-left.png'
import mockup5 from '../assets/Product Mockups/IMG_5536-portrait.png'
import mockup6 from '../assets/Product Mockups/IMG_5537-portrait.png'
import mockup7 from '../assets/Product Mockups/IMG_5538-left.png'
import mockup8 from '../assets/Product Mockups/IMG_5539-portrait.png'
import mockup9 from '../assets/Product Mockups/IMG_5540-portrait.png'
import { useEffect, useRef, forwardRef, useState } from 'react'
import { motion } from 'framer-motion'

const features = [
  {
    icon: '📍',
    title: 'Find Local Pantries',
    description: 'Discover nearby food pantries with integrated maps and get directions instantly',
    mockup: mockup1
  },
  {
    icon: '📢',
    title: 'Real-Time News Stream',
    description: 'Stay updated with live alerts and announcements from all registered pantries',
    mockup: mockup2
  },
  {
    icon: '📦',
    title: 'Browse Inventory',
    description: 'See exactly what food items are available at each pantry before you visit',
    mockup: mockup3
  },
  {
    icon: '🙋',
    title: 'Volunteer Sign Up',
    description: 'Register as a volunteer and start making a difference in your community',
    mockup: mockup5
  },
  {
    icon: '📅',
    title: 'Volunteer Scheduling',
    description: 'View available shifts at pantries and sign up for volunteer opportunities',
    mockup: mockup6
  },
  {
    icon: '🔔',
    title: 'Push Notifications',
    description: 'Get instant alerts when new food becomes available or shifts open up',
    mockup: mockup8
  }
]

const MobileEx = forwardRef((props, ref) => {
    const navigate = useNavigate()

    return (
        <Box component="section" aria-label="PantryLink Mobile App Features for Food Banks">
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          whileInView={{ opacity: 1, scale: 1 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8 }}
        >
          <motion.div
            animate={{
              background: [
                'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
                'linear-gradient(135deg, #f5576c 0%, #f093fb 100%)',
                'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)'
              ]
            }}
            transition={{ duration: 8, repeat: Infinity, ease: "easeInOut" }}
            style={{
              borderRadius: 'var(--mantine-radius-xl)',
              overflow: 'hidden'
            }}
          >
            <Paper
              p="xl"
              radius="xl"
              shadow="xl"
              style={{
                background: 'inherit',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                flexDirection: 'column',
                boxShadow: '0 25px 50px rgba(240, 147, 251, 0.5), 0 15px 30px rgba(245, 87, 108, 0.4)',
                padding: '3rem 2rem'
              }}
            >
              {/* Header Section */}
              <motion.div
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6, delay: 0.2 }}
                style={{ textAlign: 'center', marginBottom: '2rem' }}
              >
                <Title 
                  order={2}
                  size="2.5em"
                  fw={900}
                  style={{ color: 'white', marginBottom: '0.5rem' }}
                >
                  Everything Your Food Bank Needs
                </Title>
                <Text 
                  size="1.5em"
                  fw={600}
                  component="p"
                  style={{ color: 'white', opacity: 0.9 }}
                >
                  In one free iOS app
                </Text>
              </motion.div>

              {/* Features Grid with Mockups */}
              <Box ref={ref} {...props} style={{ width: '100%', maxWidth: '1200px' }}>
                {features.map((feature, index) => (
                  <motion.div
                    key={feature.title}
                    initial={{ opacity: 0, y: 50 }}
                    whileInView={{ opacity: 1, y: 0 }}
                    viewport={{ once: true }}
                    transition={{ duration: 0.6, delay: 0.1 * index }}
                    style={{ marginBottom: '3rem' }}
                  >
                    <Flex
                      direction={index % 2 === 0 ? 'row' : 'row-reverse'}
                      align="center"
                      justify="center"
                      gap="xl"
                      wrap="wrap"
                    >
                      {/* Mockup Image */}
                      <motion.div
                        whileHover={{ scale: 1.05, rotate: index % 2 === 0 ? -2 : 2 }}
                        transition={{ duration: 0.3 }}
                        style={{ flex: '0 0 auto' }}
                      >
                        <Image 
                          src={feature.mockup} 
                          alt={`PantryLink app screenshot showing ${feature.title.toLowerCase()} feature`}
                          h={350}
                          w="auto"
                          fit="contain"
                          style={{ 
                            borderRadius: '20px',
                            boxShadow: '0 20px 40px rgba(0, 0, 0, 0.3)'
                          }}
                        />
                      </motion.div>

                      {/* Feature Description */}
                      <Paper
                        p="xl"
                        radius="lg"
                        style={{
                          background: 'rgba(255, 255, 255, 0.15)',
                          backdropFilter: 'blur(20px)',
                          border: '1px solid rgba(255, 255, 255, 0.2)',
                          maxWidth: '400px',
                          flex: '1 1 300px'
                        }}
                      >
                        <motion.div
                          whileHover={{ scale: 1.02 }}
                          transition={{ duration: 0.2 }}
                        >
                          <Text size="3rem" mb="xs">{feature.icon}</Text>
                          <Title order={3} size="1.5rem" fw={700} style={{ color: 'white', marginBottom: '0.5rem' }}>
                            {feature.title}
                          </Title>
                          <Text size="md" style={{ color: 'white', opacity: 0.9 }}>
                            {feature.description}
                          </Text>
                        </motion.div>
                      </Paper>
                    </Flex>
                  </motion.div>
                ))}
              </Box>

              {/* App Store Download Section */}
              <motion.div
                initial={{ opacity: 0, y: 50 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.8, delay: 0.4 }}
                style={{ marginTop: '2rem', width: '100%' }}
              >
                <Paper
                  p="lg"
                  radius="lg"
                  shadow="md"
                  style={{
                    background: 'rgba(255, 255, 255, 0.2)',
                    backdropFilter: 'blur(20px)',
                    border: '1px solid rgba(255, 255, 255, 0.3)',
                    maxWidth: '700px',
                    margin: '0 auto'
                  }}
                >
                  <Flex align="center" justify="center" gap="lg" wrap="wrap">
                    <Image 
                      src={Logo} 
                      alt="PantryLink app icon" 
                      w={60} 
                      h={60} 
                      fit="contain"
                      style={{ borderRadius: '12px' }} 
                    />
                    <div style={{ flex: 1, minWidth: '200px' }}>
                      <Title order={3} size="xl" fw={700} style={{ color: 'white', marginBottom: '0.25rem' }}>
                        Download PantryLink Free
                      </Title>
                      <Text size="md" style={{ color: 'white', opacity: 0.9 }}>
                        Available now on iOS • 100% Free
                      </Text>
                    </div>
                    <a 
                      href="https://apps.apple.com/us/app/pantrylink/id6754800608" 
                      target="_blank" 
                      rel="noopener noreferrer"
                      aria-label="Download PantryLink on the App Store"
                      style={{ textDecoration: 'none' }}
                    >
                      <motion.div
                        whileHover={{ scale: 1.05, y: -3 }}
                        whileTap={{ scale: 0.95 }}
                        transition={{ duration: 0.2 }}
                      >
                        <Image 
                          src={appstore} 
                          alt="Download on App Store" 
                          style={{ 
                            filter: 'brightness(1) invert(1)', 
                            width: '180px', 
                            height: 'auto'
                          }}
                        />
                      </motion.div>
                    </a>
                  </Flex>
                </Paper>
              </motion.div>

              {/* Quick Feature Badges */}
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6, delay: 0.6 }}
                style={{ marginTop: '1.5rem' }}
              >
                <Group justify="center" gap="sm" wrap="wrap">
                  <Badge size="lg" variant="light" style={{ background: 'rgba(255,255,255,0.2)', color: 'white', border: '1px solid rgba(255,255,255,0.3)' }}>
                    🗺️ Maps Integration
                  </Badge>
                  <Badge size="lg" variant="light" style={{ background: 'rgba(255,255,255,0.2)', color: 'white', border: '1px solid rgba(255,255,255,0.3)' }}>
                    👤 User Accounts
                  </Badge>
                  <Badge size="lg" variant="light" style={{ background: 'rgba(255,255,255,0.2)', color: 'white', border: '1px solid rgba(255,255,255,0.3)' }}>
                    💚 Donation Support
                  </Badge>
                  <Badge size="lg" variant="light" style={{ background: 'rgba(255,255,255,0.2)', color: 'white', border: '1px solid rgba(255,255,255,0.3)' }}>
                    📱 iPad Compatible
                  </Badge>
                </Group>
              </motion.div>
            </Paper>
          </motion.div>
        </motion.div>
        </Box>
    )
})

export default MobileEx;
