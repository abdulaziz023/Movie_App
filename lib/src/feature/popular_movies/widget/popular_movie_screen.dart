import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../common/constant/api_const.dart';
import '../../../common/constant/config.dart';
import '../../../common/model/movie_model.dart';
import '../../../common/style/app_colors.dart';
import '../../../common/style/app_icons.dart';
import '../../../common/util/custom_extension.dart';
import '../../detail/widget/movie_detail_screen.dart';
import '../data/popular_repository.dart';
import 'home_screen.dart';

class PopularMovieScreen extends StatefulWidget {
  const PopularMovieScreen({super.key});

  @override
  State<PopularMovieScreen> createState() => _PopularMovieScreenState();
}

class _PopularMovieScreenState extends State<PopularMovieScreen> {
  late final ScrollController controller;

  late final IPopularRepository repository;

  final ValueNotifier<List<MovieModel>> movies = ValueNotifier<List<MovieModel>>([]);
  int page = 1;
  bool isLoading=false;

  @override
  void initState() {
    super.initState();
    controller = ScrollController()..addListener(pagination);
    repository = const PopularRepository();
    getMovies();
  }

  void getMovies() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      final newMovies = await repository.getMovies(page++);

      setState(() {
        movies.value = [...movies.value, ...newMovies];
        isLoading = false;
      });
    }
  }

  void pagination() {
    if (controller.position.pixels == controller.position.maxScrollExtent) {
      getMovies();
    }
  }

  void openSearch() {
    final state = context.findAncestorStateOfType<HomeScreenState>();

    state?.pageChange(1);
    state?.focus.requestFocus();
  }

  @override
  void dispose() {
    controller
      ..removeListener(pagination)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.main,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.searchBG,
                  borderRadius: BorderRadius.all(
                    Radius.circular(16),
                  ),
                ),
                child: ListTile(
                  title: Text(
                    context.l10n.search,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textUnselected,
                    ),
                  ),
                  trailing: SvgPicture.asset(AppIcons.search),
                  onTap: openSearch,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  page = 1;
                  movies.value = [];
                  getMovies();
                },
                child: ValueListenableBuilder<List<MovieModel>>(
                  valueListenable: movies,
                  builder: (context, movieList, child) {
                    return GridView.builder(
                      controller: controller,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1 / 1.4,
                      ),
                      itemCount: movieList.length,
                      itemBuilder: (context, index) => InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MovieDetailScreen(movie: movieList[index]),
                          ),
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(
                            Radius.circular(16),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: movieList[index].posterPath != null
                                ? ApiConst.imageLoadEntry +
                                    movieList[index].posterPath!
                                : Config.noImage,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (isLoading)
              CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
