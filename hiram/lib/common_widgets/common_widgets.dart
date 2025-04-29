import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

const Color pepperBlack = Color(0xFF2E2E2E);
const Color saltWhite = Color(0xFFF5F5F5);
const Color midGray = Color(0xFFB0B0B0);
const Color accentGray = Color(0xFF888888);

class CustomTextField extends StatelessWidget {
  final String label;
  final String value;

  const CustomTextField({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: pepperBlack,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: saltWhite,
              border: Border.all(color: midGray),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              value,
              style: const TextStyle(color: pepperBlack),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTwoFields extends StatelessWidget {
  final String label1, value1, label2, value2;

  const CustomTwoFields({
    super.key,
    required this.label1,
    required this.value1,
    required this.label2,
    required this.value2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: CustomTextField(label: label1, value: value1)),
        const SizedBox(width: 10),
        Expanded(child: CustomTextField(label: label2, value: value2)),
      ],
    );
  }
}

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CustomButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: pepperBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: saltWhite,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class CustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final List<Widget> actions;

  const CustomDialog({
    super.key,
    required this.title,
    required this.message,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: saltWhite,
      title: Text(
        title,
        style: const TextStyle(color: pepperBlack, fontWeight: FontWeight.bold),
      ),
      content: Text(
        message,
        style: const TextStyle(color: pepperBlack),
      ),
      actions: actions,
    );
  }
}

class ImageCarousel extends StatelessWidget {
  final List<String> imageUrls;

  const ImageCarousel({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return imageUrls.isNotEmpty
        ? CarouselSlider(
            options: CarouselOptions(
              height: 180,
              enlargeCenterPage: true,
              enableInfiniteScroll: true,
              autoPlay: true,
            ),
            items: imageUrls.map((imageUrl) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/placeholder.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              );
            }).toList(),
          )
        : Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: midGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.image,
              size: 80,
              color: accentGray,
            ),
          );
  }
}
