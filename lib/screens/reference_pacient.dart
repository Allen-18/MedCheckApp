import 'package:flutter/material.dart';
import 'package:practice/models/post.dart';
import 'package:practice/services/remote_service.dart';

class ReferenceScreen extends StatefulWidget {
  const ReferenceScreen({Key? key}) : super(key: key);

  @override
  ReferenceScreenState createState() => ReferenceScreenState();
}

class ReferenceScreenState extends State<ReferenceScreen> {
  List<Post>? posts;
  var isLoaded = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    posts = await RemoteService().getPosts();
    if (posts != null) {
      setState(() {
        isLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Recomandari medic'),
        ),
        body: Visibility(
          visible: isLoaded,
          replacement: const Center(
            child: CircularProgressIndicator(),
          ),
          child: ListView.builder(
            itemCount: posts?.length,
            itemBuilder: (context, index) {
              return Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey,
                        )),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(posts![index].title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                            Text(
                              posts![index].body,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            )
                          ]),
                    )
                  ]));
            },
          ),
        ));
  }
}
