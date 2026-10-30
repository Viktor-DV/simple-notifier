import 'package:flutter/material.dart';

/// Root navigator for opening routes from notification taps before [Navigator] context exists.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
