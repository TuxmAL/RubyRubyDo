# -*- coding: utf-8 -*-
#
#   Copyright (C) 2009 Andrew Stromme
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License version 2,
#   or (at your option) any later version, as published by the Free
#   Software Foundation
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details
#   You should have received a copy of the GNU General Public
#   License along with this program; if not, write to the
#   Free Software Foundation, Inc.,
#   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
#   from: http://forum.kde.org/viewtopic.php?f=43&t=38177

from PyQt4.QtCore import *
from PyQt4.QtGui import *
from PyKDE4.kdecore import i18n
from PyKDE4.kdeui import *
from PyKDE4.plasma import Plasma
from PyKDE4 import plasmascript
import dbus

class TreeViewExample(plasmascript.Applet):
    def __init__(self,parent,args=None):
        plasmascript.Applet.__init__(self,parent)

    def init(self):
        self.setHasConfigurationInterface(False)
        self.setAspectRatioMode(Plasma.IgnoreAspectRatio)

        self.theme = Plasma.Svg(self)
        self.theme.setImagePath("widgets/background")
        self.setBackgroundHints(Plasma.Applet.DefaultBackground)
	self.font.seStrikeOut = true
        self.layout = QGraphicsLinearLayout(Qt.Vertical, self.applet)

        self.label = Plasma.Label(self.applet)
        self.label.setText(i18n("TreeView Example:"))
        self.layout.addItem(self.label)

        self.stringlist = QStringList()
        for i in range(1,10):
          self.stringlist.append("Item " + str(i))

        self.model = QStringListModel(self.applet)
        self.model.setStringList(self.stringlist)

        treeview = Plasma.TreeView(self.applet)
        treeview.setModel(self.model)
        self.layout.addItem(treeview)

        self.lineedit = Plasma.LineEdit(self.applet)
        self.lineedit.nativeWidget().setClearButtonShown(True)
        self.lineedit.nativeWidget().setClickMessage(i18n("Add a new string..."))
        QObject.connect(self.lineedit, SIGNAL("returnPressed()"), self.addString)
        self.layout.addItem(self.lineedit)

        self.setLayout(self.layout)
        self.resize(250,400)

    def addString(self):
        self.stringlist.append(self.lineedit.text())
        self.lineedit.nativeWidget().clear()
        self.model.setStringList(self.stringlist)

def CreateApplet(parent):
    return TreeViewExample(parent)
