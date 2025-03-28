import "package:flutter/material.dart";

class Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          child: DrawerHeader(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/profile.jpg'),
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Sudeis",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "sudiesFed@gmail.com",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        const ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 2),
          leading: Icon(Icons.home),
          title: Text("Home"),
        ),
        const ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 2),
          leading: Icon(Icons.analytics_sharp),
          title: Text("Contact us"),
        ),
        const ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 2),
          leading: Icon(Icons.settings),
          title: Text("Settings"),
        ),
        const ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 2),
          leading: Icon(Icons.feedback),
          title: Text("Feedback"),
        ),
        // SizedBox or Container to control button size
        Container(
          margin: EdgeInsets.symmetric(vertical: 20, horizontal: 30), // Adjust margins
          child: ElevatedButton(
            onPressed: () => print("button pressed"),
            child: Text("Logout" , style: TextStyle( fontSize: 16),),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12), // Adjust padding for size
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5), // Rounded corners
              ),
              elevation: 0
            ),
          ),
        ),
            Container(
            margin: EdgeInsets.symmetric(vertical: 230, horizontal: 5),
            decoration: BoxDecoration(
            color: Colors.black87, // Background color of the container
            borderRadius: BorderRadius.circular(5), // Rounded corners
            boxShadow: [
            BoxShadow(
            color: Colors.black26, // Shadow color
            blurRadius: 8, // Spread of shadow
            offset: Offset(2, 4), // Offset of shadow (x, y)
            ),
            ],
            ),
            child: Padding(
            padding: EdgeInsets.all(20), // Padding inside the container
            child: Column(
            children: [
            Text(
            "Made by Sudeis",
            style: TextStyle(
            fontSize: 18, // Font size
            fontWeight: FontWeight.bold, // Bold font weight
            color: Colors.white, // Text color
            ),
            ),
            SizedBox(height: 10), // Add space between the texts
            Text(
            "Powered by SSGI.",
            style: TextStyle(
            fontSize: 16, // Font size
            fontWeight: FontWeight.w400, // Normal weight
            color: Colors.white70, // Slightly transparent text color
            ),
            ),
            ],
            ),
            ),
            )


          

      ],
    );
  }
}
