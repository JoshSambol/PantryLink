import Hero from '../components/Hero'
import MobileEx from '../components/MobileEx'
import { Center, Flex, Space, Text, Container, Group, Paper, Grid, Button, Image, Title } from '@mantine/core'
import {useMediaQuery} from '@mantine/hooks'
import Mobile from '../components/Mobile'
import { useRef, useEffect } from 'react'
import InventoryEx from '../components/InventoryEx'
import { motion } from 'framer-motion'
import { Link, useNavigate } from 'react-router-dom'
import Privacy from './Privacy'
import VolunteerEx from '../components/VolunteerEx'
import JFCS from '../assets/JFCS.png'
import Somerset from '../assets/Somerset.png'
import Logo from '../assets/Logo.png'

function Landing() {
    const MobileExRef = useRef(null);
    const navigate = useNavigate();
    const scrollToMobileEx = () => {
        MobileExRef.current?.scrollIntoView({ behavior: 'smooth' });
    };
    const isMobile = useMediaQuery('(max-width: 768px)');
    
    // Update document title for SEO
    useEffect(() => {
        document.title = 'PantryLink - 2025 Congressional App Challenge Winner | Free Food Bank Software';
    }, []);
    
    return isMobile ? (
    <Mobile />
  ) : (
        <main role="main" aria-label="PantryLink - Food Bank Management Platform">
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.8 }}
        >
          {/* Header Alert - App Store Announcement */}
          <header role="banner">
            <Paper
              p="xs"
              component="aside"
              aria-label="App Store announcement"
              style={{
                width: '100%',
                background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
                borderRadius: 0,
                textAlign: 'center'
              }}
            >
              <Flex align="center" justify="center" gap="sm" wrap="wrap">
                <Image 
                  src={Logo} 
                  alt="PantryLink app icon - food bank management software" 
                  w={42} 
                  h={42} 
                  fit="contain"
                  style={{ borderRadius: '8px', flexShrink: 0 }} 
                />
                <div style={{ flex: 1, minWidth: 0 }}>
                  <Text size="lg" fw={600} c="white" mb={4}>
                    PantryLink - Free Food Bank App Now on iOS!
                  </Text>
                  <Text size="md" c="white" mb={0}>
                    Download our free food pantry management app today!{' '}
                    <a 
                      href="https://apps.apple.com/us/app/pantrylink/id6754800608" 
                      target="_blank" 
                      rel="noopener noreferrer"
                      aria-label="Download PantryLink on the Apple App Store"
                      style={{ 
                        color: 'white', 
                        textDecoration: 'underline',
                        fontWeight: 600
                      }}
                    >
                      Get it on the App Store
                    </a>
                  </Text>
                </div>
              </Flex>
            </Paper>
            
            {/* Congressional App Challenge Winner Banner */}
            <Paper
              p="sm"
              component="aside"
              aria-label="Congressional App Challenge Winner announcement"
              style={{
                width: '100%',
                background: 'linear-gradient(135deg, #FFD700 0%, #FFA500 100%)',
                borderRadius: 0,
                textAlign: 'center'
              }}
            >
              <Flex align="center" justify="center" gap="md" wrap="wrap">
                <Text size="2rem" aria-hidden="true">🏆</Text>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <Text size="lg" fw={700} c="dark" mb={2}>
                    2025 Congressional App Challenge Winner!
                  </Text>
                  <Text size="md" c="dark" mb={0} style={{ opacity: 0.9 }}>
                    PantryLink was selected by{' '}
                    <a 
                      href="https://watsoncoleman.house.gov/" 
                      target="_blank" 
                      rel="noopener noreferrer"
                      aria-label="Visit Representative Bonnie Watson Coleman's website"
                      style={{ 
                        color: '#1a1a2e', 
                        textDecoration: 'underline',
                        fontWeight: 600
                      }}
                    >
                      Representative Bonnie Watson Coleman
                    </a>
                    {' '}as the winner for New Jersey's 12th Congressional District
                  </Text>
                </div>
                <Text size="2rem" aria-hidden="true">🏆</Text>
              </Flex>
            </Paper>
          </header>
          <Flex   
              mih={50}
              gap="xl"
              justify="center"
              align="center"
              direction="column"
              wrap="wrap">
              {/* <Nav /> */}
              <motion.div
                initial={{ opacity: 0, y: 30 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6 }}
                whileHover={{ scale: 1.02 }}
                style={{ cursor: 'pointer' }}
              >
                <Hero onScrollClick={scrollToMobileEx}/>
              </motion.div>
              <Space h='2rem'/>
              <motion.div
                initial={{ opacity: 0, y: 30 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: 0.3 }}
                whileHover={{ scale: 1.02 }}
                style={{ cursor: 'pointer' }}
              >
                <MobileEx ref={MobileExRef}/>
              </motion.div>
              <Space h='2rem'/>
              <motion.div
                initial={{ opacity: 0, y: 30 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: 0.6 }}
                whileHover={{ scale: 1.02 }}
                style={{ cursor: 'pointer' }}
              >
                <InventoryEx />
              </motion.div>
              <Space h='2rem'/>
              <motion.div
                initial={{ opacity: 0, y: 30 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: 0.6 }}
                whileHover={{ scale: 1.02 }}
                style={{ cursor: 'pointer' }}
              >
                <VolunteerEx />
              </motion.div>
              {/* Features Section - Why Choose PantryLink */}
              <section aria-labelledby="features-heading">
                <motion.div
                  initial={{ opacity: 0, y: 30 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.6, delay: 0.75 }}
                >
                  <Container size="lg" py="xl">
                    <Paper
                      p="xl"
                      radius="lg"
                      shadow="md"
                      component="article"
                      style={{
                        background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
                        color: 'white',
                        boxShadow: '0 20px 40px rgba(102, 126, 234, 0.4), 0 10px 20px rgba(118, 75, 162, 0.3)'
                      }}
                    >
                      <Title order={2} id="features-heading" size="2xl" fw={700} ta="center" mb="xl" style={{ color: 'white' }}>
                        Why Choose PantryLink for Your Food Bank?
                      </Title>
                      <Grid>
                        <Grid.Col span={3}>
                          <motion.div
                            whileHover={{ scale: 1.05, y: -5 }}
                            transition={{ duration: 0.2 }}
                          >
                            <Paper p="md" radius="md" component="article" style={{ background: 'rgba(255,255,255,0.1)', backdropFilter: 'blur(10px)' }}>
                              <Title order={3} size="lg" fw={600} mb="xs" style={{ color: 'white' }}>📱 Mobile-First Food Bank App</Title>
                              <Text size="sm" style={{ opacity: 0.9 }}>
                                Deliver real-time updates to your clients and volunteers instantly through our free, all-in-one iOS mobile app for food pantries.
                              </Text>
                            </Paper>
                          </motion.div>
                        </Grid.Col>
                        <Grid.Col span={3}>
                          <motion.div
                            whileHover={{ scale: 1.05, y: -5 }}
                            transition={{ duration: 0.2, delay: 0.1 }}
                          >
                            <Paper p="md" radius="md" component="article" style={{ background: 'rgba(255,255,255,0.1)', backdropFilter: 'blur(10px)' }}>
                              <Title order={3} size="lg" fw={600} mb="xs" style={{ color: 'white' }}>📊 Real-Time Inventory Analytics</Title>
                              <Text size="sm" style={{ opacity: 0.9 }}>
                                Track food inventory levels, volunteer hours, and client statistics in real-time through our intuitive food bank dashboard.
                              </Text>
                            </Paper>
                          </motion.div>
                        </Grid.Col>
                        <Grid.Col span={3}>
                          <motion.div
                            whileHover={{ scale: 1.05, y: -5 }}
                            transition={{ duration: 0.2, delay: 0.2 }}
                          >
                            <Paper p="md" radius="md" component="article" style={{ background: 'rgba(255,255,255,0.1)', backdropFilter: 'blur(10px)' }}>
                              <Title order={3} size="lg" fw={600} mb="xs" style={{ color: 'white' }}>🤝 Community Focused Platform</Title>
                              <Text size="sm" style={{ opacity: 0.9 }}>
                                Built specifically for food banks, food pantries, and community organizations to better serve families in need.
                              </Text>
                            </Paper>
                          </motion.div>
                        </Grid.Col>
                        <Grid.Col span={3}>
                          <motion.div
                            whileHover={{ scale: 1.05, y: -5 }}
                            transition={{ duration: 0.2, delay: 0.2 }}
                          >
                            <Paper p="md" radius="md" component="article" style={{ background: 'rgba(255,255,255,0.1)', backdropFilter: 'blur(10px)' }}>
                              <Title order={3} size="lg" fw={600} mb="xs" style={{ color: 'white' }}>🏆 Award-Winning & Free</Title>
                              <Text size="sm" style={{ opacity: 0.9 }}>
                                Winner of the 2025 <a href="https://congressionalappchallenge.us/" target="_blank" rel="noopener noreferrer" style={{ color: 'white' }}>Congressional App Challenge</a> for NJ-12! Free nonprofit software by the Yellow Team from theCoderSchool Montgomery.
                              </Text>
                            </Paper>
                          </motion.div>
                        </Grid.Col>
                      </Grid>
                    </Paper>
                  </Container>
                </motion.div>
              </section>
              
              {/* Partners Section - Food Banks Using PantryLink */}
              <section aria-labelledby="partners-heading">
                <motion.div
                  initial={{ opacity: 0, y: 30 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.6, delay: 0.9 }}
                >
                  <Container size="lg" py="xl">
                    <Paper
                      p="xl"
                      radius="lg"
                      shadow="md"
                      component="article"
                      style={{
                        background: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
                        color: 'white',
                        boxShadow: '0 20px 40px rgba(240, 147, 251, 0.4), 0 10px 20px rgba(245, 87, 108, 0.3)'
                      }}
                    >
                      <Title order={2} id="partners-heading" size="2xl" fw={700} ta="center" mb="xl" style={{ color: 'white' }}>
                        Food Banks & Pantries Using PantryLink
                      </Title>
                      <Grid>
                        <Grid.Col span={5}>
                          <motion.div
                            whileHover={{ scale: 1.05 }}
                            transition={{ duration: 0.2 }}
                          >
                            <a href="https://www.jfcsonline.org/" target="_blank" rel="noopener noreferrer" aria-label="Visit Jewish Family and Community Services of Mercer County website" style={{textDecoration: 'none', color: 'white'}}>
                              <Image src={JFCS} alt="JFCS Mercer County food bank partner logo" width={100} height={'auto'} />
                              <Text size="sm" ta="center" style={{ opacity: 0.9 }}>Jewish Family and Community Services - Mercer County</Text>
                            </a>
                          </motion.div>
                        </Grid.Col>
                        <Grid.Col span={5}>
                          <motion.div
                            whileHover={{ scale: 1.05 }}
                            transition={{ duration: 0.2, delay: 0.1 }}
                          >
                            <a href="https://www.somersetfoodbank.org/" target="_blank" rel="noopener noreferrer" aria-label="Visit The Food Bank Network of Somerset County website" style={{textDecoration: 'none', color: 'white'}}>
                              <Image src={Somerset} alt="Somerset County Food Bank Network partner logo" width={100} height={'auto'} />
                              <Text size="sm" ta="center" style={{ opacity: 0.9 }}>The Food Bank Network of Somerset County</Text>
                            </a>
                          </motion.div>
                        </Grid.Col>
                        
                        <Grid.Col span={2}>
                          <motion.div
                            whileHover={{ scale: 1.05 }}
                            transition={{ duration: 0.2, delay: 0.3 }}
                          >
                            <Link to="/signup" aria-label="Sign up your food bank for PantryLink" style={{textDecoration: 'none', color: 'white'}}>
                              <Text size="3em" fw={700} ta="center" aria-hidden="true">🫵</Text>
                              <Text size="sm" ta="center" style={{ opacity: 0.9 }}>Get your food bank on PantryLink today</Text>
                            </Link>
                          </motion.div>
                        </Grid.Col>
                      </Grid>
                    </Paper>
                  </Container>
                </motion.div>
              </section>
              
              {/* CTA Section - Get Started with PantryLink */}
              <section aria-labelledby="cta-heading">
                <motion.div
                  initial={{ opacity: 0, y: 30 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.6, delay: 1.05 }}
                >
                  <Container size="lg" py="xl">
                    <Paper
                      p="xl"
                      radius="lg"
                      shadow="md"
                      component="article"
                      style={{
                        background: 'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)',
                        color: 'white',
                        boxShadow: '0 20px 40px rgba(67, 233, 123, 0.4), 0 10px 20px rgba(56, 249, 215, 0.3)'
                      }}
                    >
                      <Title order={2} id="cta-heading" size="2xl" fw={700} ta="center" mb="md" style={{ color: 'white' }}>
                        Ready to Transform Your Food Bank Operations?
                      </Title>
                      <Text size="lg" ta="center" mb="xl" style={{ opacity: 0.9 }}>
                        Join PantryLink today - free inventory management, volunteer scheduling, and client communication tools for your food pantry.
                      </Text>
                      <Center>
                        <motion.div
                          whileHover={{ scale: 1.05 }}
                          whileTap={{ scale: 0.95 }}
                        >
                          <Button 
                            size="lg" 
                            variant="white" 
                            color="dark"
                            radius="xl"
                            fw={600}
                            onClick={() => navigate('/signin')}
                            aria-label="Get started with PantryLink food bank software"
                          >
                            Get Started Free Today
                          </Button>
                        </motion.div>
                      </Center>
                    </Paper>
                  </Container>
                </motion.div>
              </section>
              
              {/* Footer */}
              <footer role="contentinfo">
                <motion.div
                  initial={{ opacity: 0, y: 30 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.6, delay: 0.9 }}
                >
                  <Container size="lg" py="xl">
                    <Paper
                      p="xl"
                      radius="lg"
                      shadow="md"
                      style={{
                        background: 'linear-gradient(135deg, #2c3e50 0%, #34495e 100%)',
                        color: 'white',
                        boxShadow: '0 20px 40px rgba(44, 62, 80, 0.4), 0 10px 20px rgba(52, 73, 94, 0.3)'
                      }}
                    >
                      <Group justify="center" align="center">
                        <div>
                          <Text size="lg" fw={600} mb="xs">
                            Made with ❤️ by the Yellow Team
                          </Text>
                          <Text size="sm" style={{ opacity: 0.8 }}>
                            Read more about us <Link to="/credits" aria-label="Learn about the Yellow Team developers" style={{color: 'white'}}>here</Link>
                          </Text>
                        </div>
                        
                      </Group>
                      <Text size="xs" style={{ opacity: 0.6 }} mt="md" ta="center">
                        Copyright 2025 <a href="https://thecoderschool.com/montgomery" target="_blank" rel="noopener noreferrer" aria-label="Visit theCoderSchool Montgomery website" style={{color: 'white'}}>theCoderSchool Montgomery</a>. All Rights Reserved.                      
                      </Text>
                      <Link to="/privacy" aria-label="Read PantryLink privacy policy" style={{color: 'white'}}>Privacy Policy</Link>
                    </Paper>
                  </Container>
                </motion.div>
              </footer>
          </Flex>
        </motion.div>
        </main>
    )
}

export default Landing