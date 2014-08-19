/*  This file is part of corebird, a Gtk+ linux Twitter client.
 *  Copyright (C) 2013 Timm Bäder
 *
 *  corebird is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  corebird is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with corebird.  If not, see <http://www.gnu.org/licenses/>.
 */

public class AvatarBannerWidget : Gtk.Widget {
  private Gdk.Pixbuf? banner;
  private Gdk.Pixbuf? avatar;
  public int avatar_size { get; set; default = 48; }

  private bool _round = true;
  public bool make_round {
    get {
      return _round;
    }
    set {
      this._round = value;
      this.queue_draw ();
    }
  }


  construct {
    this.set_has_window (false);
    Settings.get ().bind ("round-avatars", this, "make_round",
                          GLib.SettingsBindFlags.DEFAULT);
    get_style_context ().add_class ("avatar");
  }

  public void set_account (Account account) {
    this.avatar = account.avatar;
  }

  private async void load_banner () {

  }

  public override bool draw (Cairo.Context ct) {
    int widget_width  = this.get_allocated_width ();
    int widget_height = this.get_allocated_height ();


    draw_avatar (ct, widget_width, widget_height);

      //int x = (widget_width / 2) - (avatar.get_width () / 2);
      //int y = 0;
      //Gdk.cairo_set_source_pixbuf (ct, avatar, x, y);
      //ct.rectangle (x, y, avatar_size, avatar_size);
      //ct.fill ();

    return true;
  }

  private void draw_avatar (Cairo.Context ct, int widget_width, int widget_height) {
    if (avatar == null)
      return;


    var surface = new Cairo.Surface.similar (ct.get_target (),
                                             Cairo.Content.COLOR_ALPHA,
                                             widget_width, widget_height);
    var surf_ct = new Cairo.Context (surface);

    surf_ct.rectangle (0, 0, widget_width, widget_height);
    Gdk.cairo_set_source_pixbuf (ct, this.avatar, 0, 0);
    surf_ct.fill();

    if (_round) {
      var sc = this.get_style_context ();
      // make it round
      surf_ct.set_operator (Cairo.Operator.DEST_IN);
      surf_ct.translate (widget_width / 2, widget_height / 2);
      surf_ct.arc (0, 0, widget_width / 2, 0, 2 * Math.PI);
      surf_ct.fill ();

      // draw outline
      surf_ct.set_operator (Cairo.Operator.OVER);
      Gdk.RGBA border_color = sc.get_border_color (this.get_state_flags ());
      surf_ct.arc (0, 0, (widget_width / 2) - 0.5, 0, 2 * Math.PI);
      surf_ct.set_line_width (1.0);
      surf_ct.set_source_rgba (border_color.red, border_color.green, border_color.blue,
                          border_color.alpha);
      surf_ct.stroke ();
    }

    ct.rectangle (0, 0, widget_width, widget_height);
    ct.set_source_surface (surface, 0, 0);
    ct.fill ();

  }

  public override Gtk.SizeRequestMode get_request_mode () {
    return Gtk.SizeRequestMode.HEIGHT_FOR_WIDTH;
  }

  public override void get_preferred_width (out int min,
                                            out int nat) {

    min = avatar_size + 40; // 20px margin on either side

    if (banner != null) {
      nat = banner.get_width ();
    } else {
      nat = min;
    }
  }

  public override void get_preferred_height_for_width (int width,
                                                   out int min,
                                                   out int nat) {
    if (banner != null) {
      double ratio = (double) banner.get_width () / (double) banner.get_height ();
      nat = (int)(banner.get_height () * ratio);
      min = (int)(banner.get_height () * ratio);
    } else {
      nat = avatar_size;
      min = avatar_size;
    }
  }
}
