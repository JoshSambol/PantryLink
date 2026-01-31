import { Box, Text, TextInput, Button, Center, Container, Title, Fieldset, Anchor, Stack, Flex } from '@mantine/core'
import { useNavigate } from 'react-router-dom'
import axios from 'axios'
import { useState } from 'react'
import { notifications } from '@mantine/notifications'
import { IconCheck, IconX } from '@tabler/icons-react'

function SignupBox() {
    const [formData, setFormData] = useState({
        username: "",
        password: "",
        confirmPassword: "",
        name: "",
        address: "",

        email: "",
        phone_number: ""
    })
    const [loading, setLoading] = useState(false)
    const navigate = useNavigate()
    
    // API Base URL - point to Render deployment
    const API_BASE_URL = 'https://yellow-team.onrender.com';
    
    const handleInputChange = (field, value) => {
        setFormData(prev => ({
            ...prev,
            [field]: value
        }));
    };
    
    const handleSignUp = async() => {
        // Validation
        if (!formData.username.trim() || !formData.password.trim() || !formData.name.trim() || !formData.address.trim() || !formData.email.trim() || !formData.phone_number.trim()) {

            notifications.show({
                title: 'Error',
                message: 'Please fill in all required fields',
                color: 'red',
                icon: <IconX size={16} />,
                autoClose: 3000,
            });
            return;
        }

        if (formData.password !== formData.confirmPassword) {
            notifications.show({
                title: 'Error',
                message: 'Passwords do not match',
                color: 'red',
                icon: <IconX size={16} />,
                autoClose: 3000,
            });
            return;
        }

        if (formData.password.length < 6) {
            notifications.show({
                title: 'Error',
                message: 'Password must be at least 6 characters long',
                color: 'red',
                icon: <IconX size={16} />,
                autoClose: 3000,
            });
            return;
        }

        try {
            setLoading(true);
            const response = await axios.post(`${API_BASE_URL}/pantry/create`, {
                username: formData.username,
                password: formData.password,
                name: formData.name,
                address: formData.address,

                email: formData.email,
                phone_number: formData.phone_number
            });

            if (response.status === 201) {
                notifications.show({
                    title: 'Account Created!',
                    message: 'Your food bank account has been created successfully. Please sign in.',
                    color: 'green',
                    icon: <IconCheck size={16} />,
                    autoClose: 5000,
                });
                
                navigate('/signin');
            }
        } catch (error) {
            console.error('Sign up error:', error);
            notifications.show({
                title: 'Sign Up Failed',
                message: error.response?.data?.message || 'Failed to create account. Please try again.',
                color: 'red',
                icon: <IconX size={16} />,
                autoClose: 3000,
            });
        } finally {
            setLoading(false);
        }
    }
    
    return (
        <Center style={{ minHeight: '100vh', padding: '2rem 0' }}>
            <Container style={{ borderRadius: '40px', backgroundColor: '#fff', maxHeight: '90vh', maxWidth: '40rem', width: 'min(95%, 32rem)', margin: '1rem', padding: '1.5rem', boxSizing: 'border-box', overflowY: 'auto' }}>
                <Title order={1} style={{ padding: '1rem 0'}}>
                    Food Bank Sign Up
                </Title>
                <Center>
                    <Fieldset legend="Food bank information" bg="transparent" style={{textAlign:'left', width:"100%", margin: '1rem 0'}}>

                        <Stack spacing="md">
                            <TextInput 
                                label="Username" 
                                placeholder="Enter your username"  
                                value={formData.username} 
                                onChange={(e) => handleInputChange('username', e.target.value)} 
                                size="md" 
                                required
                            />
                            <TextInput 
                                label="Name" 
                                placeholder="Enter your pantry name"  

                                value={formData.name} 
                                onChange={(e) => handleInputChange('name', e.target.value)} 
                                size="md" 
                                required
                            />
                            <TextInput 
                                label="Address" 
                                placeholder="Enter your address"  
                                value={formData.address} 
                                onChange={(e) => handleInputChange('address', e.target.value)} 
                                size="md" 
                                required
                            />
                            <Flex direction="row" justify="space-between" gap="md" wrap="wrap">
                            <TextInput 
                                label="Email" 
                                placeholder="Enter your email"  
                                value={formData.email} 
                                onChange={(e) => handleInputChange('email', e.target.value)} 
                                size="md" 
                                type="email"
                                required
                                style={{ flex: '1 1 12rem' }}
                            />
                            <TextInput 
                                label="Phone Number" 
                                placeholder="Enter your phone number"  
                                value={formData.phone_number} 
                                onChange={(e) => handleInputChange('phone_number', e.target.value)} 
                                size="md" 
                                required
                                style={{ flex: '1 1 12rem' }}
                            />
                            </Flex>
                            <TextInput 
                                label="Password" 
                                placeholder="Enter your password"  
                                value={formData.password} 
                                onChange={(e) => handleInputChange('password', e.target.value)} 
                                size="md" 
                                type="password"
                                required
                            />
                            <TextInput 
                                label="Confirm Password" 
                                placeholder="Confirm your password"  
                                value={formData.confirmPassword} 
                                onChange={(e) => handleInputChange('confirmPassword', e.target.value)} 
                                size="md" 
                                type="password"
                                required
                            />
                        </Stack>
                    </Fieldset>
                </Center>

                <Button 
                    onClick={handleSignUp}
                    style={{ marginTop: '1rem' }}
                    variant="light" 
                    color="gray" 
                    size="md" 
                    radius="xl"
                    loading={loading}
                    disabled={loading}
                >
                    {loading ? 'Creating Account...' : 'Sign Up'}
                </Button>
                <Text style={{padding: '1.5rem 0 0 0', textAlign: 'center'}}>Already have an account? <Anchor onClick={() => navigate('/signin')}>Sign in here.</Anchor> </Text>
                
            </Container>
        </Center>
    )
}

export default SignupBox
