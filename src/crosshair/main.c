#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <ctype.h>
#include <unistd.h>
#include <fcntl.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <math.h>
#include <getopt.h>

#include <glib.h>
#include <glib-unix.h>
#include <gtk/gtk.h>
#include <gdk/gdk.h>
#include <gtk-layer-shell/gtk-layer-shell.h>
#include <cairo.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

typedef enum {
    SHAPE_DOT,
    SHAPE_RING,
    SHAPE_DOT_RING,
    SHAPE_CROSS,
    SHAPE_CROSS_DOT
} CrosshairShape;

typedef struct {
    CrosshairShape shape;
    double size;            /* Diameter / bounding box in pixels */
    GdkRGBA color;          /* Foreground color */
    double outline;         /* Outline width in pixels (0.0 = none) */
    GdkRGBA outline_color;  /* Outline color */
    double opacity;         /* Master opacity 0.0 - 1.0 */
    int offset_x;           /* Pixel offset X from screen center */
    int offset_y;           /* Pixel offset Y from screen center */
    int gap;                /* Center gap for cross shape */
    int length;             /* Bar length for cross shape */
    int thickness;          /* Line thickness for cross/ring */
    char monitor_filter[128]; /* Target monitor name or "all" */
    bool foreground;
} CrosshairConfig;

typedef struct {
    GtkWidget *window;
    GdkMonitor *monitor;
} MonitorWindow;

/* Global State */
static CrosshairConfig g_config;
static GList *g_windows = NULL; /* List of MonitorWindow* */
static char *g_config_path = NULL;

/* -------------------------------------------------------------------------- */
/* Color and Config Helpers                                                   */
/* -------------------------------------------------------------------------- */

static bool parse_color(const char *str, GdkRGBA *rgba) {
    if (!str || !*str) return false;

    while (*str && isspace(*str)) str++;

    if (str[0] == '#' && strlen(str) == 9) {
        unsigned int r, g, b, a;
        if (sscanf(str + 1, "%02x%02x%02x%02x", &r, &g, &b, &a) == 4) {
            rgba->red = r / 255.0;
            rgba->green = g / 255.0;
            rgba->blue = b / 255.0;
            rgba->alpha = a / 255.0;
            return true;
        }
    }

    return gdk_rgba_parse(rgba, str);
}

static CrosshairShape parse_shape(const char *str) {
    if (!str) return SHAPE_DOT;
    if (strcasecmp(str, "ring") == 0 || strcasecmp(str, "circle") == 0) return SHAPE_RING;
    if (strcasecmp(str, "dot-ring") == 0 || strcasecmp(str, "dot_ring") == 0 || strcasecmp(str, "dotring") == 0) return SHAPE_DOT_RING;
    if (strcasecmp(str, "cross") == 0 || strcasecmp(str, "plus") == 0) return SHAPE_CROSS;
    if (strcasecmp(str, "cross-dot") == 0 || strcasecmp(str, "cross_dot") == 0 || strcasecmp(str, "crossdot") == 0) return SHAPE_CROSS_DOT;
    return SHAPE_DOT;
}

static void init_default_config(CrosshairConfig *cfg) {
    memset(cfg, 0, sizeof(*cfg));
    cfg->shape = SHAPE_DOT;
    cfg->size = 6.0;

    /* Crisp neon green: #00FF00 */
    cfg->color.red = 0.0;
    cfg->color.green = 1.0;
    cfg->color.blue = 0.0;
    cfg->color.alpha = 1.0;

    /* 1px dark contrast border */
    cfg->outline = 1.0;
    cfg->outline_color.red = 0.0;
    cfg->outline_color.green = 0.0;
    cfg->outline_color.blue = 0.0;
    cfg->outline_color.alpha = 0.9;

    cfg->opacity = 1.0;
    cfg->offset_x = 0;
    cfg->offset_y = 0;
    cfg->gap = 3;
    cfg->length = 7;
    cfg->thickness = 2;
    g_strlcpy(cfg->monitor_filter, "all", sizeof(cfg->monitor_filter));
    cfg->foreground = false;
}

static char *get_default_config_path(void) {
    const char *xdg_config = getenv("XDG_CONFIG_HOME");
    if (xdg_config && *xdg_config) {
        return g_strdup_printf("%s/crosshair/config", xdg_config);
    }
    const char *home = getenv("HOME");
    if (home && *home) {
        return g_strdup_printf("%s/.config/crosshair/config", home);
    }
    return g_strdup("/tmp/crosshair-config");
}

static void ensure_default_config_file(const char *path) {
    if (g_file_test(path, G_FILE_TEST_EXISTS)) {
        return;
    }

    char *dir = g_path_get_dirname(path);
    g_mkdir_with_parents(dir, 0755);
    g_free(dir);

    FILE *f = fopen(path, "w");
    if (!f) return;

    fprintf(f, "# ==========================================\n");
    fprintf(f, "# Crosshair Overlay Configuration\n");
    fprintf(f, "# ==========================================\n");
    fprintf(f, "# Shape: dot, ring, dot-ring, cross, cross-dot\n");
    fprintf(f, "shape = dot\n\n");
    fprintf(f, "# Size in pixels (dot diameter or ring diameter)\n");
    fprintf(f, "size = 6.0\n\n");
    fprintf(f, "# Dot / crosshair color (hex #RRGGBB, #RRGGBBAA, or CSS color name)\n");
    fprintf(f, "color = #00FF00\n\n");
    fprintf(f, "# Outline width in pixels (0.0 to disable, recommended: 1.0 for visibility)\n");
    fprintf(f, "outline = 1.0\n\n");
    fprintf(f, "# Outline color\n");
    fprintf(f, "outline_color = #000000\n\n");
    fprintf(f, "# Overall opacity (0.1 to 1.0)\n");
    fprintf(f, "opacity = 1.0\n\n");
    fprintf(f, "# Center offset in pixels (positive or negative)\n");
    fprintf(f, "offset_x = 0\n");
    fprintf(f, "offset_y = 0\n\n");
    fprintf(f, "# Cross specific settings (only used when shape is 'cross' or 'cross-dot')\n");
    fprintf(f, "gap = 3\n");
    fprintf(f, "length = 7\n");
    fprintf(f, "thickness = 2\n\n");
    fprintf(f, "# Monitor to display on: 'all', monitor index '0', or connector name like 'eDP-1'\n");
    fprintf(f, "monitor = all\n");
    fclose(f);
}

static void load_config_file(const char *path, CrosshairConfig *cfg) {
    if (!path || !g_file_test(path, G_FILE_TEST_EXISTS)) {
        return;
    }

    FILE *f = fopen(path, "r");
    if (!f) return;

    char line[256];
    while (fgets(line, sizeof(line), f)) {
        char *p = line;
        while (*p && isspace(*p)) p++;
        if (*p == '#' || *p == ';' || *p == '\0') continue;

        char *eq = strchr(p, '=');
        if (!eq) continue;

        *eq = '\0';
        char *key = g_strstrip(p);
        char *val = g_strstrip(eq + 1);

        if (strcasecmp(key, "shape") == 0) {
            cfg->shape = parse_shape(val);
        } else if (strcasecmp(key, "size") == 0) {
            cfg->size = atof(val);
            if (cfg->size <= 0.5) cfg->size = 1.0;
        } else if (strcasecmp(key, "color") == 0) {
            parse_color(val, &cfg->color);
        } else if (strcasecmp(key, "outline") == 0) {
            cfg->outline = atof(val);
            if (cfg->outline < 0.0) cfg->outline = 0.0;
        } else if (strcasecmp(key, "outline_color") == 0) {
            parse_color(val, &cfg->outline_color);
        } else if (strcasecmp(key, "opacity") == 0) {
            cfg->opacity = atof(val);
            if (cfg->opacity < 0.05) cfg->opacity = 0.05;
            if (cfg->opacity > 1.0) cfg->opacity = 1.0;
        } else if (strcasecmp(key, "offset_x") == 0) {
            cfg->offset_x = atoi(val);
        } else if (strcasecmp(key, "offset_y") == 0) {
            cfg->offset_y = atoi(val);
        } else if (strcasecmp(key, "gap") == 0) {
            cfg->gap = atoi(val);
        } else if (strcasecmp(key, "length") == 0) {
            cfg->length = atoi(val);
        } else if (strcasecmp(key, "thickness") == 0) {
            cfg->thickness = atoi(val);
            if (cfg->thickness < 1) cfg->thickness = 1;
        } else if (strcasecmp(key, "monitor") == 0) {
            g_strlcpy(cfg->monitor_filter, val, sizeof(cfg->monitor_filter));
        }
    }
    fclose(f);
}

/* -------------------------------------------------------------------------- */
/* PID & Daemon Management                                                    */
/* -------------------------------------------------------------------------- */

static char *get_pid_file_path(void) {
    const char *runtime_dir = getenv("XDG_RUNTIME_DIR");
    if (runtime_dir && *runtime_dir) {
        return g_strdup_printf("%s/crosshair.pid", runtime_dir);
    }
    return g_strdup_printf("/tmp/crosshair-%d.pid", getuid());
}

static pid_t get_running_pid(void) {
    char *path = get_pid_file_path();
    FILE *f = fopen(path, "r");
    g_free(path);
    if (!f) return -1;

    pid_t pid = -1;
    if (fscanf(f, "%d", &pid) == 1) {
        fclose(f);
        if (pid > 0 && kill(pid, 0) == 0) {
            return pid;
        }
    } else {
        fclose(f);
    }
    return -1;
}

static void save_pid_file(void) {
    char *path = get_pid_file_path();
    FILE *f = fopen(path, "w");
    if (f) {
        fprintf(f, "%d\n", getpid());
        fclose(f);
    }
    g_free(path);
}

static void remove_pid_file(void) {
    char *path = get_pid_file_path();
    unlink(path);
    g_free(path);
}

/* -------------------------------------------------------------------------- */
/* Cairo Drawing and Input Passthrough                                        */
/* -------------------------------------------------------------------------- */

static void apply_input_shape_passthrough(GtkWidget *widget) {
    GdkWindow *gdk_win = gtk_widget_get_window(widget);
    if (gdk_win) {
        cairo_region_t *empty_region = cairo_region_create();
        gdk_window_input_shape_combine_region(gdk_win, empty_region, 0, 0);
        cairo_region_destroy(empty_region);
    }
}

static void on_widget_realize(GtkWidget *widget, gpointer user_data) { (void)user_data;
    apply_input_shape_passthrough(widget);
}

static void on_widget_map(GtkWidget *widget, gpointer user_data) { (void)user_data;
    apply_input_shape_passthrough(widget);
}

static void on_widget_size_allocate(GtkWidget *widget, GtkAllocation *alloc, gpointer user_data) { (void)alloc; (void)user_data;
    apply_input_shape_passthrough(widget);
}

static gboolean on_widget_draw(GtkWidget *widget, cairo_t *cr, gpointer user_data) { (void)user_data;
    cairo_set_operator(cr, CAIRO_OPERATOR_CLEAR);
    cairo_paint(cr);
    cairo_set_operator(cr, CAIRO_OPERATOR_OVER);

    GtkAllocation alloc;
    gtk_widget_get_allocation(widget, &alloc);

    double cx = (alloc.width / 2.0) + g_config.offset_x;
    double cy = (alloc.height / 2.0) + g_config.offset_y;

    double cr_r = g_config.color.red;
    double cr_g = g_config.color.green;
    double cr_b = g_config.color.blue;
    double cr_a = g_config.color.alpha * g_config.opacity;

    double out_r = g_config.outline_color.red;
    double out_g = g_config.outline_color.green;
    double out_b = g_config.outline_color.blue;
    double out_a = g_config.outline_color.alpha * g_config.opacity;
    double outline = g_config.outline;

    switch (g_config.shape) {
        case SHAPE_DOT: {
            double radius = g_config.size / 2.0;
            if (outline > 0.0) {
                cairo_arc(cr, cx, cy, radius + outline, 0, 2 * M_PI);
                cairo_set_source_rgba(cr, out_r, out_g, out_b, out_a);
                cairo_fill(cr);
            }
            cairo_arc(cr, cx, cy, radius, 0, 2 * M_PI);
            cairo_set_source_rgba(cr, cr_r, cr_g, cr_b, cr_a);
            cairo_fill(cr);
            break;
        }

        case SHAPE_RING: {
            double radius = g_config.size / 2.0;
            double th = g_config.thickness ? g_config.thickness : 1.5;
            if (outline > 0.0) {
                cairo_set_line_width(cr, th + outline * 2.0);
                cairo_arc(cr, cx, cy, radius, 0, 2 * M_PI);
                cairo_set_source_rgba(cr, out_r, out_g, out_b, out_a);
                cairo_stroke(cr);
            }
            cairo_set_line_width(cr, th);
            cairo_arc(cr, cx, cy, radius, 0, 2 * M_PI);
            cairo_set_source_rgba(cr, cr_r, cr_g, cr_b, cr_a);
            cairo_stroke(cr);
            break;
        }

        case SHAPE_DOT_RING: {
            double radius = g_config.size / 2.0;
            double th = g_config.thickness ? g_config.thickness : 1.5;
            if (outline > 0.0) {
                cairo_set_line_width(cr, th + outline * 2.0);
                cairo_arc(cr, cx, cy, radius, 0, 2 * M_PI);
                cairo_set_source_rgba(cr, out_r, out_g, out_b, out_a);
                cairo_stroke(cr);
            }
            cairo_set_line_width(cr, th);
            cairo_arc(cr, cx, cy, radius, 0, 2 * M_PI);
            cairo_set_source_rgba(cr, cr_r, cr_g, cr_b, cr_a);
            cairo_stroke(cr);

            double dot_r = 1.5;
            if (outline > 0.0) {
                cairo_arc(cr, cx, cy, dot_r + outline, 0, 2 * M_PI);
                cairo_set_source_rgba(cr, out_r, out_g, out_b, out_a);
                cairo_fill(cr);
            }
            cairo_arc(cr, cx, cy, dot_r, 0, 2 * M_PI);
            cairo_set_source_rgba(cr, cr_r, cr_g, cr_b, cr_a);
            cairo_fill(cr);
            break;
        }

        case SHAPE_CROSS:
        case SHAPE_CROSS_DOT: {
            double gap = g_config.gap;
            double len = g_config.length;
            double th = g_config.thickness;

            double bars[4][4] = {
                { cx - gap - len, cy - th / 2.0, len, th },
                { cx + gap,       cy - th / 2.0, len, th },
                { cx - th / 2.0, cy - gap - len, th, len },
                { cx - th / 2.0, cy + gap,       th, len }
            };

            if (outline > 0.0) {
                cairo_set_source_rgba(cr, out_r, out_g, out_b, out_a);
                for (int i = 0; i < 4; i++) {
                    cairo_rectangle(cr,
                                    bars[i][0] - outline,
                                    bars[i][1] - outline,
                                    bars[i][2] + outline * 2.0,
                                    bars[i][3] + outline * 2.0);
                    cairo_fill(cr);
                }
            }

            cairo_set_source_rgba(cr, cr_r, cr_g, cr_b, cr_a);
            for (int i = 0; i < 4; i++) {
                cairo_rectangle(cr, bars[i][0], bars[i][1], bars[i][2], bars[i][3]);
                cairo_fill(cr);
            }

            if (g_config.shape == SHAPE_CROSS_DOT) {
                double dot_r = (th > 2) ? (th / 2.0) : 1.5;
                if (outline > 0.0) {
                    cairo_arc(cr, cx, cy, dot_r + outline, 0, 2 * M_PI);
                    cairo_set_source_rgba(cr, out_r, out_g, out_b, out_a);
                    cairo_fill(cr);
                }
                cairo_arc(cr, cx, cy, dot_r, 0, 2 * M_PI);
                cairo_set_source_rgba(cr, cr_r, cr_g, cr_b, cr_a);
                cairo_fill(cr);
            }
            break;
        }
    }

    return FALSE;
}

/* -------------------------------------------------------------------------- */
/* Layer Shell Window Creation                                                */
/* -------------------------------------------------------------------------- */

static bool matches_monitor(GdkMonitor *monitor, int index) {
    if (strcasecmp(g_config.monitor_filter, "all") == 0) {
        return true;
    }

    char idx_str[16];
    snprintf(idx_str, sizeof(idx_str), "%d", index);
    if (strcmp(g_config.monitor_filter, idx_str) == 0) {
        return true;
    }

    const char *model = gdk_monitor_get_model(monitor);
    if (model && strstr(model, g_config.monitor_filter)) {
        return true;
    }

    return false;
}

static GtkWidget *create_crosshair_window(GdkMonitor *monitor) {
    GtkWidget *win = gtk_window_new(GTK_WINDOW_TOPLEVEL);

    gtk_layer_init_for_window(GTK_WINDOW(win));
    gtk_layer_set_layer(GTK_WINDOW(win), GTK_LAYER_SHELL_LAYER_OVERLAY);
    gtk_layer_set_keyboard_mode(GTK_WINDOW(win), GTK_LAYER_SHELL_KEYBOARD_MODE_NONE);
    gtk_layer_set_exclusive_zone(GTK_WINDOW(win), -1);
    gtk_layer_set_namespace(GTK_WINDOW(win), "crosshair");

    if (monitor) {
        gtk_layer_set_monitor(GTK_WINDOW(win), monitor);
    }

    gtk_layer_set_anchor(GTK_WINDOW(win), GTK_LAYER_SHELL_EDGE_LEFT, FALSE);
    gtk_layer_set_anchor(GTK_WINDOW(win), GTK_LAYER_SHELL_EDGE_RIGHT, FALSE);
    gtk_layer_set_anchor(GTK_WINDOW(win), GTK_LAYER_SHELL_EDGE_TOP, FALSE);
    gtk_layer_set_anchor(GTK_WINDOW(win), GTK_LAYER_SHELL_EDGE_BOTTOM, FALSE);

    int req_span = (int)ceil(g_config.size + g_config.outline * 2.0);
    if (g_config.shape == SHAPE_CROSS || g_config.shape == SHAPE_CROSS_DOT) {
        req_span = (g_config.gap + g_config.length + (int)ceil(g_config.outline)) * 2;
    }
    int offset_max = MAX(abs(g_config.offset_x), abs(g_config.offset_y));
    int canvas_dim = MAX(64, (req_span + offset_max + 16) * 2);
    if (canvas_dim % 2 != 0) canvas_dim++;

    gtk_widget_set_size_request(win, canvas_dim, canvas_dim);

    GdkScreen *screen = gtk_widget_get_screen(win);
    GdkVisual *visual = gdk_screen_get_rgba_visual(screen);
    if (visual) {
        gtk_widget_set_visual(win, visual);
    }
    gtk_widget_set_app_paintable(win, TRUE);

    g_signal_connect(win, "realize", G_CALLBACK(on_widget_realize), NULL);
    g_signal_connect(win, "map", G_CALLBACK(on_widget_map), NULL);
    g_signal_connect(win, "size-allocate", G_CALLBACK(on_widget_size_allocate), NULL);
    g_signal_connect(win, "draw", G_CALLBACK(on_widget_draw), NULL);

    gtk_widget_show_all(win);
    return win;
}

static void rebuild_windows(void) {
    for (GList *l = g_windows; l != NULL; l = l->next) {
        MonitorWindow *mw = (MonitorWindow *)l->data;
        if (mw->window && GTK_IS_WIDGET(mw->window)) {
            gtk_widget_destroy(mw->window);
        }
        g_free(mw);
    }
    g_list_free(g_windows);
    g_windows = NULL;

    GdkDisplay *display = gdk_display_get_default();
    if (!display) return;

    int n_monitors = gdk_display_get_n_monitors(display);
    for (int i = 0; i < n_monitors; i++) {
        GdkMonitor *mon = gdk_display_get_monitor(display, i);
        if (matches_monitor(mon, i)) {
            MonitorWindow *mw = g_new0(MonitorWindow, 1);
            mw->monitor = mon;
            mw->window = create_crosshair_window(mon);
            g_windows = g_list_append(g_windows, mw);
        }
    }
}


static void on_monitor_added(GdkDisplay *display, GdkMonitor *monitor, gpointer user_data) { (void)display; (void)monitor; (void)user_data;
    rebuild_windows();
}

static void on_monitor_removed(GdkDisplay *display, GdkMonitor *monitor, gpointer user_data) { (void)display; (void)monitor; (void)user_data;
    rebuild_windows();
}

/* -------------------------------------------------------------------------- */
/* Signal Handlers                                                            */
/* -------------------------------------------------------------------------- */

static gboolean on_sigterm(gpointer user_data) { (void)user_data;
    remove_pid_file();
    gtk_main_quit();
    return G_SOURCE_REMOVE;
}

static gboolean on_sighup(gpointer user_data) { (void)user_data;
    if (g_config_path) {
        load_config_file(g_config_path, &g_config);
        rebuild_windows();
    }
    return G_SOURCE_CONTINUE;
}

/* -------------------------------------------------------------------------- */
/* CLI and Main Entry Point                                                   */
/* -------------------------------------------------------------------------- */

static void print_usage(const char *prog) {
    printf("Usage: %s [COMMAND] [OPTIONS]\n\n", prog);
    printf("A lightweight, click-through screen crosshair overlay for Wayland/Hyprland.\n\n");
    printf("Commands:\n");
    printf("  start               Start the crosshair (default action)\n");
    printf("  stop                Stop running crosshair instance\n");
    printf("  toggle              Toggle crosshair on or off\n");
    printf("  status              Check if crosshair is running\n");
    printf("  reload              Reload configuration file without restarting\n\n");
    printf("Options:\n");
    printf("  -s, --size <px>         Size / diameter in pixels (default: 6.0)\n");
    printf("  -c, --color <val>       Color: hex (#00FF00) or name (default: #00FF00)\n");
    printf("  -o, --outline <px>      Outline width in pixels (default: 1.0, 0 to disable)\n");
    printf("  -O, --outline-color <v> Outline color (default: #000000)\n");
    printf("  -p, --shape <shape>     Shape: dot, ring, dot-ring, cross, cross-dot (default: dot)\n");
    printf("  -a, --opacity <0.1-1.0> Overall opacity (default: 1.0)\n");
    printf("  -x, --offset-x <px>     Horizontal offset from center (default: 0)\n");
    printf("  -y, --offset-y <px>     Vertical offset from center (default: 0)\n");
    printf("  -m, --monitor <name>    Monitor filter ('all', index '0', or name) (default: all)\n");
    printf("  -f, --foreground        Run in foreground (do not detach into background)\n");
    printf("      --config <path>     Custom config file path\n");
    printf("  -h, --help              Show this help message\n");
}

int main(int argc, char **argv) {
    init_default_config(&g_config);

    g_config_path = get_default_config_path();
    ensure_default_config_file(g_config_path);
    load_config_file(g_config_path, &g_config);

    const char *action = "start";
    int opt_start_idx = 1;
    if (argc > 1 && argv[1][0] != '-') {
        action = argv[1];
        opt_start_idx = 2;
    }

    if (strcasecmp(action, "status") == 0) {
        pid_t pid = get_running_pid();
        if (pid > 0) {
            printf("Crosshair is running (PID %d)\n", pid);
            return 0;
        } else {
            printf("Crosshair is not running\n");
            return 1;
        }
    }

    if (strcasecmp(action, "stop") == 0) {
        pid_t pid = get_running_pid();
        if (pid > 0) {
            kill(pid, SIGTERM);
            for (int i = 0; i < 20; i++) {
                if (kill(pid, 0) != 0) break;
                usleep(50000);
            }
            remove_pid_file();
            printf("Crosshair stopped (PID %d)\n", pid);
            return 0;
        } else {
            printf("Crosshair is not running\n");
            return 0;
        }
    }

    if (strcasecmp(action, "toggle") == 0) {
        pid_t pid = get_running_pid();
        if (pid > 0) {
            kill(pid, SIGTERM);
            for (int i = 0; i < 20; i++) {
                if (kill(pid, 0) != 0) break;
                usleep(50000);
            }
            remove_pid_file();
            printf("Crosshair turned OFF\n");
            return 0;
        }
        action = "start";
    }

    if (strcasecmp(action, "reload") == 0) {
        pid_t pid = get_running_pid();
        if (pid > 0) {
            kill(pid, SIGUSR1);
            kill(pid, SIGHUP);
            printf("Reload signal sent to crosshair (PID %d)\n", pid);
            return 0;
        } else {
            fprintf(stderr, "Crosshair is not running\n");
            return 1;
        }
    }

    if (strcasecmp(action, "help") == 0 || strcasecmp(action, "--help") == 0 || strcasecmp(action, "-h") == 0) {
        print_usage(argv[0]);
        return 0;
    }

    static struct option long_options[] = {
        {"size",          required_argument, 0, 's'},
        {"color",         required_argument, 0, 'c'},
        {"outline",       required_argument, 0, 'o'},
        {"outline-color", required_argument, 0, 'O'},
        {"shape",         required_argument, 0, 'p'},
        {"opacity",       required_argument, 0, 'a'},
        {"offset-x",      required_argument, 0, 'x'},
        {"offset-y",      required_argument, 0, 'y'},
        {"monitor",       required_argument, 0, 'm'},
        {"foreground",    no_argument,       0, 'f'},
        {"config",        required_argument, 0, 1000},
        {"help",          no_argument,       0, 'h'},
        {0, 0, 0, 0}
    };

    optind = opt_start_idx;
    int opt;
    while ((opt = getopt_long(argc, argv, "s:c:o:O:p:a:x:y:m:fh", long_options, NULL)) != -1) {
        switch (opt) {
            case 's': g_config.size = atof(optarg); break;
            case 'c': parse_color(optarg, &g_config.color); break;
            case 'o': g_config.outline = atof(optarg); break;
            case 'O': parse_color(optarg, &g_config.outline_color); break;
            case 'p': g_config.shape = parse_shape(optarg); break;
            case 'a': g_config.opacity = atof(optarg); break;
            case 'x': g_config.offset_x = atoi(optarg); break;
            case 'y': g_config.offset_y = atoi(optarg); break;
            case 'm': g_strlcpy(g_config.monitor_filter, optarg, sizeof(g_config.monitor_filter)); break;
            case 'f': g_config.foreground = true; break;
            case 1000:
                g_free(g_config_path);
                g_config_path = g_strdup(optarg);
                load_config_file(g_config_path, &g_config);
                break;
            case 'h':
                print_usage(argv[0]);
                return 0;
            default:
                print_usage(argv[0]);
                return 1;
        }
    }

    pid_t existing_pid = get_running_pid();
    if (existing_pid > 0) {
        fprintf(stderr, "Crosshair is already running (PID %d).\nUse 'crosshair toggle' or 'crosshair stop'.\n", existing_pid);
        return 1;
    }

    if (!g_config.foreground) {
        pid_t child = fork();
        if (child < 0) {
            perror("fork");
            return 1;
        }
        if (child > 0) {
            printf("Crosshair turned ON (PID %d)\n", child);
            return 0;
        }

        setsid();
        int devnull = open("/dev/null", O_RDWR);
        if (devnull >= 0) {
            dup2(devnull, STDIN_FILENO);
            dup2(devnull, STDOUT_FILENO);
            dup2(devnull, STDERR_FILENO);
            if (devnull > 2) close(devnull);
        }
    }

    save_pid_file();

    gtk_init(NULL, NULL);

    if (!gtk_layer_is_supported()) {
        fprintf(stderr, "Fatal error: Wayland layer-shell protocol is not supported by your compositor.\n");
        remove_pid_file();
        return 1;
    }

    g_unix_signal_add(SIGTERM, on_sigterm, NULL);
    g_unix_signal_add(SIGINT, on_sigterm, NULL);
    g_unix_signal_add(SIGHUP, on_sighup, NULL);
    g_unix_signal_add(SIGUSR1, on_sighup, NULL);

    GdkDisplay *display = gdk_display_get_default();
    if (display) {
        g_signal_connect(display, "monitor-added", G_CALLBACK(on_monitor_added), NULL);
        g_signal_connect(display, "monitor-removed", G_CALLBACK(on_monitor_removed), NULL);
    }

    rebuild_windows();

    gtk_main();

    remove_pid_file();
    return 0;
}
