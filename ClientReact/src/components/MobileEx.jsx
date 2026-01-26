import { Container, Title, Text, Button, Center, Image, Flex, Paper, Group, Badge, Stack, Box } from '@mantine/core'
import { useNavigate } from 'react-router-dom'
import homePageBottom from '../assets/homePageBottom.png'
import homePageTop from '../assets/homePageTop.png'
import appstore from '../assets/appstore.svg'
import Logo from '../assets/Logo.png'
import { useEffect, useRef, forwardRef, useState } from 'react'
import { motion } from 'framer-motion'

const MobileEx = forwardRef((props, ref) => {
    const navigate = useNavigate()

    return (
        <Box component="section" aria-label="PantryLink Mobile App for Food Banks">
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
                minHeight: '100vh',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                flexDirection: 'column',
                boxShadow: '0 25px 50px rgba(240, 147, 251, 0.5), 0 15px 30px rgba(245, 87, 108, 0.4)'
              }}
            >
              <motion.div
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6, delay: 0.2 }}
                whileHover={{ scale: 1.05, y: -5 }}
                style={{ cursor: 'pointer' }}
              >
                <Title 
                  order={2}
                  size="2em"
                  fw={900}
                  style={{ color: 'white', textAlign: 'center' }}
                >
                  Connect Food Banks to Clients Seamlessly
                </Title>
              </motion.div>
              <motion.div
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6, delay: 0.4 }}
                whileHover={{ scale: 1.05, y: -5 }}
                style={{ cursor: 'pointer' }}
              >
                <Text 
                  size="3em"
                  fw={900}
                  component="p"
                  style={{ color: 'white', opacity: 0.9, textAlign: 'center' }}
                >
                  Through our free iOS mobile app for food pantries
                </Text>
              </motion.div>
              
              <Center ref={ref} {...props}>
                <motion.div
                  initial={{ opacity: 0, y: 50 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.8, delay: 0.6 }}
                >
                  <Flex
                    mih={50}
                    gap={"5rem"}
                    justify="center"
                    align="flex-start"
                    direction="row"
                    wrap="wrap"
                  >
                    <motion.div
                      initial={{ opacity: 0, x: -50 }}
                      whileInView={{ opacity: 1, x: 0 }}
                      viewport={{ once: true }}
                      transition={{ duration: 0.6, delay: 0.8 }}
                      whileHover={{ scale: 1.1, y: -15, rotate: -2 }}
                      style={{ cursor: 'pointer' }}
                    >
                      <Image h={400} w={'auto'} src={homePageTop} alt="PantryLink iOS mobile app home screen showing food bank inventory and donation tracking" />
                    </motion.div>
                    <motion.div
                      initial={{ opacity: 0, x: 50 }}
                      whileInView={{ opacity: 1, x: 0 }}
                      viewport={{ once: true }}
                      transition={{ duration: 0.6, delay: 1.0 }}
                      whileHover={{ scale: 1.1, y: -15, rotate: 2 }}
                      style={{ cursor: 'pointer' }}
                    >
                      <Image h={400} w={'auto'} src={homePageBottom} alt="PantryLink mobile app showing real-time food pantry updates and notifications" />
                    </motion.div>
                  </Flex>
                </motion.div>
              </Center>

              {/* Professional App Store Download Section */}
              <motion.div
                initial={{ opacity: 0, y: 50 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.8, delay: 1.2 }}
                style={{ marginTop: '1rem', width: '100%' }}
              >
                <Paper
                  p="md"
                  radius="lg"
                  shadow="md"
                  style={{
                    background: 'rgba(255, 255, 255, 0.15)',
                    backdropFilter: 'blur(20px)',
                    border: '1px solid rgba(255, 255, 255, 0.2)',
                    maxWidth: '600px',
                    margin: '0 auto'
                  }}
                >
                  <Stack spacing={0} align="center" style={{ width: '100%' }}>
                    <motion.div
                      initial={{ opacity: 0, scale: 0.9 }}
                      whileInView={{ opacity: 1, scale: 1 }}
                      viewport={{ once: true }}
                      transition={{ duration: 0.6, delay: 1.4 }}
                      style={{ width: '100%', marginBottom: '0.5rem' }}
                    >
                      <Flex align="center" justify="center" gap="sm" wrap="wrap" direction="column">
                        <Image 
                          src={Logo} 
                          alt="PantryLink Logo" 
                          w={52} 
                          h={52} 
                          fit="contain"
                          style={{ borderRadius: '10px', marginBottom: '0.5rem' }} 
                        />
                        <div>
                          <Text 
                            size="xl" 
                            fw={700} 
                            style={{ color: 'white', textAlign: 'center', marginBottom: '0.25rem' }}
                          >
                            Download PantryLink Mobile
                          </Text>
                          <Text 
                            size="md" 
                            style={{ color: 'white', opacity: 0.9, textAlign: 'center', marginBottom: 0 }}
                          >
                            Available on iOS devices only.
                          </Text>
                        </div>
                      </Flex>
                    </motion.div>

                    <motion.div
                      initial={{ opacity: 0, y: 10 }}
                      whileInView={{ opacity: 1, y: 0 }}
                      viewport={{ once: true }}
                      transition={{ duration: 0.6, delay: 1.6 }}
                      style={{ width: '100%', display: 'flex', justifyContent: 'center', marginBottom: '0.5rem' }}
                    >
                        {/* App Store Badge */}
                        <a 
                          href="https://apps.apple.com/us/app/pantrylink/id6754800608" 
                          target="_blank" 
                          rel="noopener noreferrer"
                          style={{ textDecoration: 'none', display: 'inline-block' }}
                        >
                          <motion.div
                            whileHover={{ scale: 1.05, y: -5 }}
                            whileTap={{ scale: 0.95 }}
                            transition={{ duration: 0.2 }}
                            style={{ cursor: 'pointer', display: 'inline-block', padding: '0' }}
                          >
                                <Image 
                                  src={appstore} 
                                  alt="Download on App Store" 
                                  style={{ 
                                    filter: 'brightness(1) invert(1)', 
                                    width: '200px', 
                                    maxWidth: '100%', 
                                    height: 'auto', 
                                    display: 'block',
                                    margin: '-20px 0 -15px 0',
                                    padding: '0'
                                  }}
                                />
                          </motion.div>
                        </a>
                    </motion.div>

                    {/* App Features */}
                    <motion.div
                      initial={{ opacity: 0, y: 10 }}
                      whileInView={{ opacity: 1, y: 0 }}
                      viewport={{ once: true }}
                      transition={{ duration: 0.6, delay: 1.8 }}
                      style={{ width: '100%', marginTop: '0.5rem' }}
                    >
                      <Group justify="center" gap={8} wrap="wrap">
                        <Badge 
                          size="md" 
                          variant="light" 
                          style={{ 
                            background: 'rgba(255, 255, 255, 0.2)', 
                            color: 'white',
                            border: '1px solid rgba(255, 255, 255, 0.3)',
                            fontSize: '1em'
                          }}
                        >
                          📱 Real-time Updates
                        </Badge>
                        <Badge 
                          size="md" 
                          variant="light" 
                          style={{ 
                            background: 'rgba(255, 255, 255, 0.2)', 
                            color: 'white',
                            border: '1px solid rgba(255, 255, 255, 0.3)',
                            fontSize: '1em'
                          }}
                        >
                          🔔 Push Notifications
                        </Badge>
                        <Badge 
                          size="md" 
                          variant="light" 
                          style={{ 
                            background: 'rgba(255, 255, 255, 0.2)', 
                            color: 'white',
                            border: '1px solid rgba(255, 255, 255, 0.3)',
                            fontSize: '1em'
                          }}
                        >
                          📊 Live Analytics
                        </Badge>
                      </Group>
                    </motion.div>
                  </Stack>
                </Paper>
              </motion.div>
            </Paper>
          </motion.div>
        </motion.div>
        </Box>
    )
})

export default MobileEx;