#ifndef LAUNCHERAPP_H
#define LAUNCHERAPP_H

#include <ilixiGUI.h>
#include <map>
#include <string>

#include "widgets/launchertoolbar.h"
#include "activities/baseactivity.h"

// Make argc and argv static since they are used by the singleton app
namespace ProgramArgs {
    static int argc;
    static char** argv;
}

// Singleton application object
// Also set theme properties
class LauncherApp : public ilixi::Application
{
    public:
        static LauncherApp& instance();

        // This method allow an activity to register a widget in the toolbar
        // If there are several widgets, pack them into a ContainerWidget
        void registerToolBarWidget(const std::string& activityName, ilixi::Widget* widget);

        void showActivity(const std::string& activityName);
        void showPreviousActivity();

        // Return stylist object
        ilixi::StylistBase* stylist() const;

        // Static method that allow widget to load icons
        static ilixi::Icon* loadLauncherIcon(const std::string& name);
        static ilixi::Icon* loadIcon(const std::string& name, const int width);
        static std::string iconPathForName(const std::string& name);

    private:
        LauncherApp(int* argc, char*** argv);
        std::string _executableDir;

        LauncherToolBar *_toolBar;
        ilixi::ToolButton *_menuButton;

        std::map<std::string, ilixi::Widget*> _toolBarWidgetsMap;
        std::map<std::string, BaseActivity*> _activitiesMap;
        std::string _launchedActivity = "";
        std::string _previousActivity = "";

        void registerActivity(BaseActivity *act);

        static LauncherApp _instance;
};

#endif // LAUNCHERAPP_H
