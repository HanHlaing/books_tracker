import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

bool get isIOS => Platform.isIOS;

Route<T> adaptiveRoute<T>({required WidgetBuilder builder}) {
  if (isIOS) return CupertinoPageRoute<T>(builder: builder);
  return MaterialPageRoute<T>(builder: builder);
}

Widget adaptiveProgressIndicator({Color? color}) {
  if (isIOS) return CupertinoActivityIndicator(color: color);
  return CircularProgressIndicator(color: color);
}
