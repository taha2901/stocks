
import 'package:flutter/material.dart';
import 'package:management_stock/core/routing/routers.dart';
import 'package:management_stock/core/widgets/custom_button.dart';

class AddAndReturnBusttons extends StatelessWidget {
  const AddAndReturnBusttons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: "إضافة عميل جديد",
            icon: Icons.person_add,
            onPressed: () {
              Navigator.pushNamed(context, Routers.addCustomerRoute);
            },
            backgroundColor: Colors.blueAccent,
            textColor: Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        CustomButton(
          text: "العودة",
          icon: Icons.arrow_back,
          isOutlined: true,
          borderColor: Colors.grey,
          textColor: Colors.grey[300],
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
