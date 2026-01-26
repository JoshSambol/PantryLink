import { Box, Button, Title, Text, Image, Paper, Flex, Group, Badge, Stack, Container } from "@mantine/core";
import { motion } from "framer-motion"
import appstore from "../assets/appstore.svg"
import Logo from "../assets/Logo.png"

function Mobile() {
    return (
        <Box style={{ 
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
                            {/* Header */}
                            <motion.div
                                initial={{ opacity: 0, scale: 0.9 }}
                                animate={{ opacity: 1, scale: 1 }}
                                transition={{ duration: 0.6, delay: 0.2 }}
                            >
                                <Flex align="center" justify="center" gap="sm" mb="md" wrap="wrap" direction="column">
                                    <Image 
                                        src={Logo} 
                                        alt="PantryLink Logo" 
                                        w={58} 
                                        h={58} 
                                        fit="contain"
                                        style={{ borderRadius: '10px', marginBottom: '0.5rem' }} 
                                    />
                                    <div style={{ textAlign: 'center' }}>
                                        <Title order={1} size="2.5rem" fw={800} style={{ color: 'white', marginBottom: '0.5rem' }}>
                                            PantryLink Mobile
                                        </Title>
                                        <Text size="lg" style={{ color: 'white', opacity: 0.9 }}>
                                            Connect with your community on the go
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
                                <Flex align="center" justify="center" gap="sm" wrap="wrap" direction="column">
                                    <Image 
                                        src={Logo} 
                                        alt="PantryLink Logo" 
                                        w={48} 
                                        h={48} 
                                        fit="contain"
                                        style={{ borderRadius: '8px', marginBottom: '0.5rem' }} 
                                    />
                                    <div style={{ textAlign: 'center' }}>
                                        <Text size="xl" fw={700} style={{ color: 'white', marginBottom: '0.5rem' }}>
                                            Download Our Mobile App
                                        </Text>
                                        <Text size="md" style={{ color: 'white', opacity: 0.9, marginBottom: '0.75rem' }}>
                                            Available on iOS devices only.
                                        </Text>
                                    </div>
                                </Flex>

                                <Group justify="center" gap="xs" wrap="wrap" mt="xs">
                                    {/* App Store Badge */}
                                    <a 
                                      href="http://apps.apple.com/us/app/pantrylink/id6754800608" 
                                      target="_blank" 
                                      rel="noopener noreferrer"
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
                                              alt="Download on App Store" 
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
                                <Text size="lg" fw={600} style={{ color: 'white', marginBottom: '1rem' }}>
                                    Key Features
                                </Text>
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