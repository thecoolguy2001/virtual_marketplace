// lib/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/artwork.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:firebase_auth/firebase_auth.dart';

class CheckoutScreen extends StatefulWidget {
  final Artwork artwork;

  const CheckoutScreen({Key? key, required this.artwork}) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Payment form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Loading state
  bool _isLoading = false;


@override
void initState() {
  super.initState();

  Stripe.instance.applySettings(
    publishableKey: "YOUR_STRIPE_PUBLISHABLE_KEY",  
    merchantIdentifier: "merchant.com.yourapp",    
    urlScheme: 'yourapp',                           
  );
}


  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Handle payment process
  Future<void> _handlePayment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create a payment method
      PaymentMethod paymentMethod = await StripePayment.paymentRequestWithCardForm(
        CardFormPaymentRequest(),
      );

      // Create a payment intent on the server
      // For this example, we'll assume you have a backend endpoint to create payment intents
      // Replace 'YOUR_BACKEND_URL' with your actual backend endpoint
      final response = await _createPaymentIntent(widget.artwork.price, widget.artwork.currency);
      if (response == null) {
        throw Exception('Failed to create payment intent');
      }

      // Confirm the payment
      PaymentIntentResult paymentIntent = await StripePayment.confirmPaymentIntent(
        PaymentIntent(
          clientSecret: response['client_secret'],
          paymentMethodId: paymentMethod.id,
        ),
      );

      if (paymentIntent.status == 'succeeded') {
        // Payment successful
        await _completePurchase();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment Successful!')),
        );

        // Navigate to HomeScreen or Order Confirmation
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        throw Exception('Payment failed');
      }
    } catch (e) {
      print('Payment Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Failed: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Mock function to create payment intent
  // Replace this with actual server call
  Future<Map<String, dynamic>?> _createPaymentIntent(double amount, String currency) async {
    // Normally, you'd make an HTTP request to your backend to create a payment intent
    // Here, we'll mock the response
    // IMPORTANT: Never handle secret keys on the client side
    // Implement a secure backend to handle payment intents

    // For demonstration, returning null
    // Implement proper backend integration
    return null;
  }

  // Complete the purchase (e.g., save order details to Firestore)
  Future<void> _completePurchase() async {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    // Create a purchase record
    await firestoreService.addPurchase({
      'buyerId': currentUser.uid,
      'artworkId': widget.artwork.id,
      'price': widget.artwork.price,
      'currency': widget.artwork.currency,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyService = Provider.of<CurrencyService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Artwork Details
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Image.network(
                    widget.artwork.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.artwork.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    '\$${widget.artwork.price.toStringAsFixed(2)} ${widget.artwork.currency}',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Payment Form
            Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Billing Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Address Field
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Payment Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handlePayment,
                      child: _isLoading 
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text('Pay Now'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}