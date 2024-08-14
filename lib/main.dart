import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';

void main() {
  usePathUrlStrategy();

  runApp(
    WidgetCatalog(
      catalog: [
        MyFancyWidget.catalog,
        CatalogWidget(
          name: 'InputField',
          description: 'Description 1',
          builder: (BuildContext context) {
            return Container(
              width: 400,
              height: 200,
              color: Colors.red,
              child: const Text('InputField'),
            );
          },
        ),
        CatalogWidget(
          name: 'Container',
          description: 'Description 2',
          keywords: ['nice', 'hause', 'banana'],
          builder: (BuildContext context) {
            return Container(color: Colors.blue, child: const Text('ListTile'));
          },
        ),
        CatalogWidget(
          name: 'Overlay',
          description: 'Description 3',
          pageBuilder: (BuildContext context, Widget child) {
            return Container(
              color: Colors.purple,
              child: Column(
                children: [
                  const Text('Wrapper'),
                  Container(
                    color: Colors.green,
                    child: const Text('Overlay'),
                  ),
                ],
              ),
            );
          },
          builder: (BuildContext context) {
            return Container(color: Colors.green, child: const Text('Overlay'));
          },
        ),
        CatalogWidget(
          name: 'InputTextField',
          description: 'Description 4',
          builder: (BuildContext context) {
            return Container(color: Colors.yellow, child: const Text('InputTextField'));
          },
        ),
        CatalogWidget(
          name: 'FancyInputField',
          description: 'Description 4',
          builder: (BuildContext context) {
            return Container(color: Colors.yellow, child: const Text('FancyInputField'));
          },
        ),
      ],
      widgetPageBuilder: (context, CatalogWidget widget) {
        return Center(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.ac_unit_rounded),
                  onPressed: () {
                    // Open Github
                  },
                ),
              ),
              Center(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('Tags:'),
                  ...widget.keywords.map((keyword) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            context.go(context.namedLocation('home', queryParameters: {'q': keyword}));
                          },
                          child: Chip(
                            label: Text(keyword),
                          ),
                        ),
                      ),
                    );
                  }),
                ]),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    widget.pageBuilder?.call(context, widget.builder(context)) ?? widget.builder(context),
                    if (widget.description != null) Text(widget.description!),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      homePageBuilder: (context, List<CatalogWidget> widgets) {
        return const HomePage();
      },
    ),
  );
}

class MyFancyWidget extends StatelessWidget {
  const MyFancyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orangeAccent,
      child: const Center(child: Text('MyFancyWidget')),
    );
  }

  static final catalog = CatalogWidget(
    name: 'FancyInputField',
    description: 'Description 4',
    keywords: ['fancy', 'my'],
    builder: (BuildContext context) {
      return const MyFancyWidget();
    },
  );
}

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final catalog = InheritedCatalog.of(context).catalog;
    return Padding(
      padding: const EdgeInsets.all(64.0),
      child: Column(
        children: [
          const Row(
            children: [
              QueryTag(
                query: 'Input',
              ),
              SizedBox(width: 16),
              QueryTag(
                query: 'banana',
              )
            ],
          ),
          Expanded(
            child: GridView(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 200),
              children: catalog.map((widget) {
                return WidgetTile(widget: widget);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class WidgetTile extends StatefulWidget {
  const WidgetTile({
    required this.widget,
    super.key,
  });

  final CatalogWidget widget;

  @override
  State<WidgetTile> createState() => _WidgetTileState();
}

class _WidgetTileState extends State<WidgetTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          context.push(widget.widget.path);
        },
        child: Card(
          color: _isHovered ? Colors.grey[200] : Colors.white,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.widget.name),
                widget.widget.builder(context),
                Text(widget.widget.keywords.join(', ')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WidgetCatalog extends StatefulWidget {
  const WidgetCatalog({
    super.key,
    required this.homePageBuilder,
    required this.widgetPageBuilder,
    required this.catalog,
  });

  final Widget Function(BuildContext context, List<CatalogWidget> groups) homePageBuilder;

  final Widget Function(BuildContext context, CatalogWidget widget) widgetPageBuilder;

  final List<CatalogWidget> catalog;

  @override
  State<WidgetCatalog> createState() => _WidgetCatalogState();
}

class _WidgetCatalogState extends State<WidgetCatalog> {
  late final GoRouter _router = GoRouter(
    routes: <RouteBase>[
      ShellRoute(
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (context, state) {
              final query = state.uri.queryParameters['q'];
              if (query != null) {
                final results = _getSearchResults(query);
                return NoTransitionPage(
                  child: InheritedCatalog(
                    catalog: results,
                    child: widget.homePageBuilder(
                      context,
                      results,
                    ),
                  ),
                );
              }
              return NoTransitionPage(
                child: widget.homePageBuilder(
                  context,
                  InheritedCatalog.of(context).catalog,
                ),
              );
            },
            routes: widget.catalog.map((widget) {
              return GoRoute(
                  path: widget.name,
                  pageBuilder: (context, state) {
                    return NoTransitionPage(
                      child: this.widget.widgetPageBuilder(context, widget),
                    );
                  });
            }).toList(),
          ),
        ],
        builder: (context, state, child) {
          return CatalogShell(
            catalog: widget.catalog,
            queryParameters: state.uri.queryParameters,
            child: child,
          );
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }

  List<CatalogWidget> _getSearchResults(String query) {
    final results = <CatalogWidget>[];

    for (var widget in widget.catalog) {
      if (widget.name.toLowerCase().contains(query.toLowerCase()) ||
          widget.description?.toLowerCase().contains(query.toLowerCase()) == true ||
          widget.keywords.any((keyword) => keyword.toLowerCase().contains(query.toLowerCase()))) {
        results.add(widget);
      }
    }

    return results;
  }
}

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.onChanged,
    required this.controller,
  });

  final void Function(String input) onChanged;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          flex: 1,
          child: SizedBox(),
        ),
        Expanded(
          flex: 2,
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            onChanged: onChanged,
          ),
        ),
        const Expanded(
          flex: 1,
          child: SizedBox(),
        ),
      ],
    );
  }
}

class CatalogWidget {
  CatalogWidget({
    required this.name,
    required this.builder,
    this.pageBuilder,
    this.description,
    this.keywords = const [],
  });

  final String name;
  final String? description;
  final WidgetBuilder builder;
  final Widget Function(BuildContext context, Widget child)? pageBuilder;
  final List<String> keywords;

  String get path => '/$name';
}

class InheritedCatalog extends InheritedWidget {
  const InheritedCatalog({
    super.key,
    required this.catalog,
    required super.child,
  });

  final List<CatalogWidget> catalog;

  static InheritedCatalog of(BuildContext context) {
    final InheritedCatalog? result = context.dependOnInheritedWidgetOfExactType<InheritedCatalog>();
    assert(result != null, 'No InheritedCatalog found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(InheritedCatalog oldWidget) {
    return catalog != oldWidget.catalog;
  }
}

class CatalogShell extends StatefulWidget {
  const CatalogShell({
    super.key,
    required this.child,
    required this.catalog,
    this.queryParameters,
  });

  final Widget child;
  final List<CatalogWidget> catalog;
  final Map<String, String>? queryParameters;

  @override
  State<CatalogShell> createState() => _CatalogShellState();
}

class _CatalogShellState extends State<CatalogShell> {
  late List<CatalogWidget> _catalog = widget.catalog;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    updateSearchPhrase();
  }

  @override
  void didUpdateWidget(covariant CatalogShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.catalog != widget.catalog) {
      _catalog = widget.catalog;
    }
    if (oldWidget.queryParameters != widget.queryParameters) {
      updateSearchPhrase();
    }
  }

  @override
  Widget build(BuildContext context) {
    GoRouterState state = GoRouterState.of(context);
    final StatelessWidget title;
    if (state.topRoute?.path == '/') {
      title = SearchField(
        controller: _searchController,
        onChanged: (String input) {
          if (input.isEmpty) {
            setState(() {
              _catalog = widget.catalog;
            });
            context.go('/');
            return;
          }
          context.go(context.namedLocation('home', queryParameters: {'q': input}));
        },
      );
    } else {
      title = Text(state.topRoute!.path);
    }
    return InheritedCatalog(
      catalog: _catalog,
      child: Scaffold(
        appBar: AppBar(
          title: title,
          leading: _buildLeadingButton(context),
        ),
        body: widget.child,
      ),
    );
  }

  void updateSearchPhrase() {
    final query = widget.queryParameters?['q'];
    if (_searchController.text != query) {
      _searchController.text = query ?? '';
    }
  }

  /// Builds the app bar leading button using the current location [Uri].
  ///
  /// Copy from https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/shell_route_top_route.dart#L182-L195
  ///
  /// The [Scaffold]'s default back button cannot be used because it doesn't
  /// have the context of the current child.
  Widget? _buildLeadingButton(BuildContext context) {
    final RouteMatchList currentConfiguration = GoRouter.of(context).routerDelegate.currentConfiguration;
    final RouteMatch lastMatch = currentConfiguration.last;
    final Uri location = lastMatch is ImperativeRouteMatch ? lastMatch.matches.uri : currentConfiguration.uri;
    final bool canPop = location.pathSegments.isNotEmpty;
    return canPop ? BackButton(onPressed: GoRouter.of(context).pop) : null;
  }
}

class QueryTag extends StatelessWidget {
  const QueryTag({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.go(context.namedLocation('home', queryParameters: {'q': query}));
        },
        child: Container(
          width: 100,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
            color: Colors.purple,
          ),
          child: Center(
            child: Text(query),
          ),
        ),
      ),
    );
  }
}
