import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PostShimmer extends StatelessWidget {
  final int count;
  const PostShimmer({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: count * 250,
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 8,
      ),
      child: Shimmer.fromColors(
        baseColor: Color.fromARGB(134, 235, 235, 235),
        highlightColor: Color.fromARGB(113, 185, 185, 185),
        enabled: true,
        child: ListView.builder(
          itemBuilder: (_, __) => Container(
            margin: const EdgeInsets.only(bottom: 32,),
            padding: const EdgeInsets.all(8,),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8,),
              color: Color(0x50ffffff),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 20,
                  color: Colors.white,
                ),
                SizedBox(height: 24,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ...[1, 2, 3, 4]
                    .map((i) {
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 4,),
                        height: 8.0,
                        color: Colors.white,
                      );
                    }),
                    Container(
                      width: 40,
                      height: 8,
                      color: Colors.white,
                    ),
                  ],
                ),
                SizedBox(height: 24,),
                Row(
                  children: [
                    const Icon(Icons.thumb_up,),
                    const SizedBox(width: 16,),
                    const Icon(Icons.comment_outlined,),
                  ],
                ),
              ],
            ),
          ),
          itemCount: count,
        ),
      ),
    );
  }
}
