import { Box, Button, Title, Text, Image, Paper, Flex, Group, Badge, Stack, Container } from "@mantine/core";
import { motion } from "framer-motion"
import appstore from "../assets/appstore.svg"
import Logo from "../assets/Logo.png"
import { useEffect } from "react"

function Mobile() {
    // Update document title for SEO on mobile
    useEffect(() => {
        document.title = 'PantryLink - 2025 Congressional App Challenge Winner | Free Food Bank App';
    }, []);

    return (
        <Box 
            component="main"
            role="main"
            aria-label="PantryLink - Free Food Bank Management App"
            style={{ 
                background: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)', 
                padding: '2rem', 
                textAlign: 'center', 
                minHeight: '100vh', 
                minWidth: '100vw',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center'
            }}>
            <Container size="sm">
                <motion.div
                    initial={{ opacity: 0, y: 30 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.8 }}
                >
                    <Paper
                        p="xl"
                        radius="lg"
                        shadow="xl"
                        style={{
                            background: 'rgba(255, 255, 255, 0.15)',
                            backdropFilter: 'blur(20px)',
                            border: '1px solid rgba(255, 255, 255, 0.2)',
                            color: 'white'
                        }}
                    >
                        <Stack spacing="xl" align="center">
                            {/* Congressional App Challenge Winner Badge */}
                            <motion.div
                                initial={{ opacity: 0, scale: 0.8 }}
                                animate={{ opacity: 1, scale: 1 }}
                                transition={{ duration: 0.6, delay: 0.1 }}
                            >
                                <Paper
                                    p="sm"
                                    radius="md"
                                    style={{
                                        background: 'linear-gradient(135deg, #FFD700 0%, #FFA500 100%)',
                                        textAlign: 'center'
                                    }}
                                >
                                    <Text size="xl" fw={700} c="dark" mb={4}>
                                        🏆 2025 Congressional App Challenge Winner 🏆
                                    </Text>
                                    <Text size="sm" c="dark" style={{ opacity: 0.9 }}>
                                        Selected by Rep. Bonnie Watson Coleman for NJ-12
                                    </Text>
                                </Paper>
                            </motion.div>

                            {/* Header */}
                            <motion.div
                                initial={{ opacity: 0, scale: 0.9 }}
                                animate={{ opacity: 1, scale: 1 }}
                                transition={{ duration: 0.6, delay: 0.2 }}
                            >
                                <Flex align="center" justify="center" gap="sm" mb="md" wrap="wrap" direction="column">
                                    <Image 
                                        src={Logo} 
                                        alt="PantryLink app icon - award-winning free food bank management software for iOS" 
                                        w={58} 
                                        h={58} 
                                        fit="contain"
                                        style={{ borderRadius: '10px', marginBottom: '0.5rem' }} 
                                    />
                                    <div style={{ textAlign: 'center' }}>
                                        <Title order={1} size="2rem" fw={800} style={{ color: 'white', marginBottom: '0.5rem' }}>
                                            PantryLink: Award-Winning Food Bank App
                                        </Title>
                                        <Text size="lg" component="p" style={{ color: 'white', opacity: 0.9 }}>
                                            Manage inventory, schedule volunteers, and connect with your community
                                        </Text>
                                    </div>
                                </Flex>
                            </motion.div>

                            {/* App Store Download Section */}
                            <motion.div
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ duration: 0.6, delay: 0.4 }}
                            >
                                <Flex align="center" justify="center" gap="sm" wrap="wrap" direction="column" component="section" aria-label="Download PantryLink">
                                    <Image 
                                        src={Logo} 
                                        alt="PantryLink food bank management app logo" 
                                        w={48} 
                                        h={48} 
                                        fit="contain"
                                        style={{ borderRadius: '8px', marginBottom: '0.5rem' }} 
                                    />
                                    <div style={{ textAlign: 'center' }}>
                                        <Title order={2} size="xl" fw={700} style={{ color: 'white', marginBottom: '0.5rem' }}>
                                            Download PantryLink Free
                                        </Title>
                                        <Text size="md" component="p" style={{ color: 'white', opacity: 0.9, marginBottom: '0.75rem' }}>
                                            Free food bank software for iOS - track donations, manage inventory & volunteers.
                                        </Text>
                                    </div>
                                </Flex>

                                <Group justify="center" gap="xs" wrap="wrap" mt="xs">
                                    {/* App Store Badge */}
                                    <a 
                                      href="https://apps.apple.com/us/app/pantrylink/id6754800608" 
                                      target="_blank" 
                                      rel="noopener noreferrer"
                                      aria-label="Download PantryLink free on the Apple App Store"
                                      style={{ textDecoration: 'none', display: 'inline-block' }}
                                    >
                                      <motion.div
                                          whileHover={{ scale: 1.05, y: -5 }}
                                          whileTap={{ scale: 0.95 }}
                                          transition={{ duration: 0.2 }}
                                          style={{ cursor: 'pointer', padding: '0' }}
                                      >
                                          <Image 
                                              src={appstore} 
                                              alt="Download PantryLink on the Apple App Store - free food bank management app" 
                                              width={160} 
                                              height="auto"
                                              style={{ 
                                                  filter: 'brightness(1) invert(1)',
                                                  display: 'block',
                                                  margin: '-15px 0 -12px 0',
                                                  padding: '0'
                                              }}
                                          />
                                      </motion.div>
                                    </a>

                                    
                                </Group>
                            </motion.div>

                            {/* App Features */}
                            <motion.div
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ duration: 0.6, delay: 0.6 }}
                            >
                                <Title order={3} size="lg" fw={600} style={{ color: 'white', marginBottom: '1rem' }}>
                                    Food Bank Management Features
                                </Title>
                                <Group justify="center" gap="md" wrap="wrap">
                                    <Badge 
                                        size="lg" 
                                        variant="light" 
                                        style={{ 
                                            background: 'rgba(255, 255, 255, 0.2)', 
                                            color: 'white',
                                            border: '1px solid rgba(255, 255, 255, 0.3)'
                                        }}
                                    >
                                        📱 Real-time Updates
                                    </Badge>
                                    <Badge 
                                        size="lg" 
                                        variant="light" 
                                        style={{ 
                                            background: 'rgba(255, 255, 255, 0.2)', 
                                            color: 'white',
                                            border: '1px solid rgba(255, 255, 255, 0.3)'
                                        }}
                                    >
                                        🔔 Push Notifications
                                    </Badge>
                                    <Badge 
                                        size="lg" 
                                        variant="light" 
                                        style={{ 
                                            background: 'rgba(255, 255, 255, 0.2)', 
                                            color: 'white',
                                            border: '1px solid rgba(255, 255, 255, 0.3)'
                                        }}
                                    >
                                        📊 Live Analytics
                                    </Badge>
                                </Group>
                            </motion.div>

                            {/* Download Stats */}
                            <motion.div
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ duration: 0.6, delay: 0.8 }}
                            >
                            </motion.div>
                        </Stack>
                    </Paper>
                </motion.div>
            </Container>
        </Box>
    )
}

export default Mobile