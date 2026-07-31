const std = @import("std");
const std_compat = @import("compat");

pub const InjectedStrings = struct {
    reflection_prompt: ?[]const u8 = null,
    empty_response_retry: ?[]const u8 = null,
    force_follow_through: ?[]const u8 = null,
    max_iterations: ?[]const u8 = null,
    skip_tool_descriptions_native: bool = false,
    safety_section: ?[]const u8 = null,
    channel_choices: ?[]const u8 = null,
    scheduled_tasks_group: ?[]const u8 = null,
};

/// Load injected strings override from a JSON file.
/// Returns null if file cannot be opened or parsed.
/// Caller owns returned strings (allocated with allocator).
pub fn load(allocator: std.mem.Allocator, path: []const u8) ?InjectedStrings {
    const file = std_compat.fs.openFileAbsolute(path, .{}) catch return null;
    defer file.close();
    const content = file.readToEndAlloc(allocator, 256 * 1024) catch return null;
    defer allocator.free(content);

    var parsed = std.json.parseFromSlice(std.json.Value, allocator, content, .{}) catch return null;
    defer parsed.deinit();

    if (parsed.value != .object) return null;
    const obj = parsed.value.object;

    var result = InjectedStrings{};

    if (obj.get("reflection_prompt")) |v| {
        if (v == .string) result.reflection_prompt = allocator.dupe(u8, v.string) catch null;
    }
    if (obj.get("empty_response_retry")) |v| {
        if (v == .string) result.empty_response_retry = allocator.dupe(u8, v.string) catch null;
    }
    if (obj.get("force_follow_through")) |v| {
        if (v == .string) result.force_follow_through = allocator.dupe(u8, v.string) catch null;
    }
    if (obj.get("max_iterations")) |v| {
        if (v == .string) result.max_iterations = allocator.dupe(u8, v.string) catch null;
    }
    if (obj.get("skip_tool_descriptions_native")) |v| {
        if (v == .bool) result.skip_tool_descriptions_native = v.bool;
    }
    if (obj.get("safety_section")) |v| {
        if (v == .string) result.safety_section = allocator.dupe(u8, v.string) catch null;
    }
    if (obj.get("channel_choices")) |v| {
        if (v == .string) result.channel_choices = allocator.dupe(u8, v.string) catch null;
    }
    if (obj.get("scheduled_tasks_group")) |v| {
        if (v == .string) result.scheduled_tasks_group = allocator.dupe(u8, v.string) catch null;
    }

    return result;
}
