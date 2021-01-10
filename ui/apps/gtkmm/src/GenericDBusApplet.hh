// GenericDBusApplet.hh --- X11 Applet Window
//
// Copyright (C) 2001 - 2009, 2011, 2012, 2013 Rob Caelers & Raymond Penners
// All rights reserved.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#ifndef GENERICDBUSAPPLET_HH
#define GENERICDBUSAPPLET_HH

#include <string>
#include <set>

#include "AppletWindow.hh"
#include "commonui/TimerBoxViewBase.hh"
#include "MenuBase.hh"

#include "dbus/IDBusWatch.hh"
#include "utils/ScopedConnections.hh"

class AppletControl;

namespace workrave
{
  namespace dbus
  {
    class DBus;
  }
} // namespace workrave

class GenericDBusApplet
  : public AppletWindow
  , public TimerBoxViewBase
  , public MenuBase
  , public workrave::dbus::IDBusWatch
{
public:
  struct TimerData
  {
    std::string bar_text;
    int slot;
    int bar_secondary_color;
    int bar_secondary_val;
    int bar_secondary_max;
    int bar_primary_color;
    int bar_primary_val;
    int bar_primary_max;
  };

  struct MenuItem
  {
    std::string text;
    int command;
    int flags;
  };

  using MenuItems = std::list<MenuItem>;

  GenericDBusApplet();
  ~GenericDBusApplet() override = default;

  // DBus
  virtual void get_menu(MenuItems &out) const;
  virtual void get_tray_icon_enabled(bool &enabled) const;
  virtual void applet_command(int command);
  virtual void applet_embed(bool enable, const std::string &sender);
  virtual void button_clicked(int button);

private:
  // IAppletWindow
  void init_applet() override;

  // ITimerBoxView
  void set_slot(workrave::BreakId id, int slot) override;
  void set_time_bar(workrave::BreakId id,
                    int value,
                    TimerColorId primary_color,
                    int primary_value,
                    int primary_max,
                    TimerColorId secondary_color,
                    int secondary_value,
                    int secondary_max) override;
  void update_view() override;
  bool is_visible() const override;

  // IDBusWatch
  void bus_name_presence(const std::string &name, bool present) override;

  // Menu
  void resync(workrave::OperationMode mode, workrave::UsageMode usage) override;

  void add_menu_item(const char *text, int command, int flags);

  void send_tray_icon_enabled();

private:
  bool visible{false};
  bool embedded{false};
  TimerData data[workrave::BREAK_ID_SIZEOF];
  MenuItems items;
  std::set<std::string> active_bus_names;
  workrave::dbus::IDBus::Ptr dbus;
  scoped_connections connections;
};

#endif // GENERICDBUSAPPLET_HH
